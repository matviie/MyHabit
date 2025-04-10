import SwiftUI
import CoreData
import FirebaseAuth

class HabitsViewModel: ObservableObject {
    
    @AppStorage("uid") var userID: String = ""
    
    @Published var addNewHabit: Bool = false
    @Published var editHabitFlag: Bool = false
    @Published var title: String = ""
    @Published var habitColor: String = "card-1"
    @Published var weekDays: [String] = []
    @Published var isRemainderOn: Bool = false
    @Published var notificationDate: Date = Date()
    @Published var remainderText: String = ""
    @Published var completedDates: [Date] = []
    
    @Published var habits: [Habit] = []
    
    func loadHabits(context: NSManagedObjectContext) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let request = NSFetchRequest<Habit>(entityName: "Habit")
        request.predicate = NSPredicate(format: "userID == %@", uid)

        do {
            habits = try context.fetch(request)
        } catch {
            print("❌ Failed to fetch habits: \(error)")
            habits = []
        }
    }
    
    
    // Прапор для показу таймера для вибору часу нагадування
    @Published var showTimePicker: Bool = false
    
    // Для зберігання звички, яку редагує користувач
    @Published var editHabit: Habit?
    
    // Прапор для перевірки доступу до сповіщень
    @Published var notificationAccess: Bool = false
    
    // Ініціалізація та запит на доступ до сповіщень
    init() {
        requestNotificationAccess()
    }
    
    // MARK: Запит на доступ до сповіщень
    func requestNotificationAccess() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert]) { status , _ in
            DispatchQueue.main.async {
                self.notificationAccess = status
            }
        }
    }
    
    // MARK: Додавання звички в базу даних
    func addHabit(context: NSManagedObjectContext) async -> Bool {
        
        guard let uid = Auth.auth().currentUser?.uid else { return false }
        
        // MARK: Редагування даних
        var habit: Habit!
        // Якщо редагуємо існуючу звичку, то обираємо її
        if let editHabit = editHabit {
            habit = editHabit
            // Видаляємо всі очікуючі сповіщення для цієї звички
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: editHabit.notificationIDs ?? [])
        } else {
            habit = Habit(context: context) // Створюємо нову звичку
            habit.id = UUID() // Генеруємо унікальний ID
            habit.dateAdded = Date() // Додаємо дату додавання
            habit.userID = uid
        }
        
        // Присвоюємо властивості звички
        habit.title = title
        habit.color = habitColor
        habit.weekDays = weekDays
        habit.isRemainderOn = isRemainderOn
        habit.remainderText = remainderText
        habit.notificationDate = notificationDate
        habit.notificationIDs = []
        habit.completedDates = completedDates
        
        // Якщо нагадування увімкнено, плануємо сповіщення
        if isRemainderOn {
            if let ids = try? await schedulingNotifications() {
                habit.notificationIDs = ids // Зберігаємо ідентифікатори сповіщень
                if let _ = try? context.save() { // Зберігаємо зміни в базі
                    return true
                }
            }
        } else {
            // Якщо нагадування вимкнено, просто зберігаємо без сповіщень
            if let _ = try? context.save() {
                return true
            }
        }
        
        return false
    }
    
    // MARK: Додавання сповіщень
    func schedulingNotifications() async throws -> [String] {
        let content = UNMutableNotificationContent()
        content.title = "Habit Reminder"
        content.subtitle = remainderText
        content.sound = UNNotificationSound.default
        
        // Ідентифікатори запланованих сповіщень
        var notificationIDs: [String] = []
        let calendar = Calendar.current
        let weekDaySymbols: [String] = calendar.weekdaySymbols // Дні тижня
        
        // MARK: Планування сповіщень для кожного дня
        for weekDay in weekDays {
            let id = UUID().uuidString
            let hour = calendar.component(.hour, from: notificationDate)
            let min = calendar.component(.minute, from: notificationDate)
            let day = weekDaySymbols.firstIndex { $0 == weekDay } ?? -1
            
            if day != -1 {
                var components = DateComponents()
                components.hour = hour
                components.minute = min
                components.weekday = day + 1 // Задаємо день тижня
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                
                try await UNUserNotificationCenter.current().add(request)
                notificationIDs.append(id)
            }
        }
        
        return notificationIDs
    }
    
    func resetData() {
        title = ""
        habitColor = "card-1"
        weekDays = []
        isRemainderOn = false
        notificationDate = Date()
        remainderText = ""
        completedDates = []
        editHabit = nil
    }
    
    func deleteHabit(context: NSManagedObjectContext) -> Bool {
        if let editHabit = editHabit {
            if editHabit.isRemainderOn {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: editHabit.notificationIDs ?? [])
            }
            context.delete(editHabit)
            if let _ = try? context.save() {
                return true
            }
        }
        return false
    }
    
    // MARK: Відновлення даних для редагування
    func restoreEditData() {
        if let editHabit = editHabit {
            title = editHabit.title ?? ""
            habitColor = editHabit.color ?? "card-1"
            weekDays = editHabit.weekDays ?? []
            isRemainderOn = editHabit.isRemainderOn
            notificationDate = editHabit.notificationDate ?? Date()
            remainderText = editHabit.remainderText ?? ""
            completedDates = editHabit.completedDates ?? []
        }
    }
    
    // MARK: Статус кнопки "Done"
    func doneStatus() -> Bool {
        let remainderStatus = isRemainderOn ? remainderText.isEmpty : false
        return !(title.isEmpty || weekDays.isEmpty || remainderStatus)
    }
    
    // MARK: Збереження звички
    func saveHabit(context: NSManagedObjectContext) async -> Bool {
        if let existingHabit = editHabit {
            existingHabit.title = title
            existingHabit.color = habitColor
            existingHabit.weekDays = weekDays
            existingHabit.isRemainderOn = isRemainderOn
            existingHabit.notificationDate = notificationDate
            existingHabit.remainderText = remainderText
            existingHabit.completedDates = completedDates
                
            do {
                try context.save()
                return true
            } catch {
                print("Failed to save habit: \(error)")
                return false
            }
        } else {
            // Якщо це нова звичка, створюємо новий об'єкт Habit
            let newHabit = Habit(context: context)
            newHabit.title = title
            newHabit.color = habitColor
            newHabit.weekDays = weekDays
            newHabit.isRemainderOn = isRemainderOn
            newHabit.notificationDate = notificationDate
            newHabit.remainderText = remainderText
                
            do {
                try context.save()
                return true
            } catch {
                print("Failed to save habit: \(error)")
                return false
            }
        }
    }
    
    var strengthCalculationPeriod: Int { 30 }
    
    // обчислення сили звички у відсотках
    var strengthPercentage: Int {
        calculateStrengthPercentage(completedDates: completedDates)
    }
    
    // кількість днів поспіль, коли звичка виконувалася
    var streak: Int {
        let dates = processDatesForStreakCalculation(completedDates)
        guard let firstDate = dates.first else { return 0 }
        guard firstDate.isInSameDay(as: Date()) else { return 0 }

        var previousDate = firstDate
        var streak = 1

        for date in dates.dropFirst() {
            let daysBetweenDates = previousDate.days(from: date)
            if daysBetweenDates <= 1 {
                streak += 1
            } else {
                return streak
            }
            previousDate = date
        }
        return streak
    }
    
    // найдовший стрик за всю історію звички
    var longestStreak: Int {
        let dates = processDatesForStreakCalculation(completedDates)
        guard let firstDate = dates.first else { return 0 }

        var previousDate = firstDate
        var currentStreak = 1
        var longestStreak = 0

        for date in dates.dropFirst() {
            let daysBetweenDates = previousDate.days(from: date)
            if daysBetweenDates <= 1 {
                currentStreak += 1
            } else {
                longestStreak = max(currentStreak, longestStreak)
                currentStreak = 1
            }
            previousDate = date
        }
        return max(currentStreak, longestStreak)
    }
    
    func processDatesForStreakCalculation(_ dates: [Date]) -> [Date] {
        let dates = dates.map { Calendar.current.startOfDay(for: $0) }
        let datesWithoutDaysAfterToday = dates.filter { $0 <= Date.now }
        let uniqueDatesWithinPeriod = datesWithoutDaysAfterToday.removingDuplicates()
        let sortedDates = uniqueDatesWithinPeriod.sorted { $0 > $1 }
        return sortedDates
    }

    func isCompleted(for date: Date) -> Bool {
        completedDates.contains { Calendar.current.isDate($0, inSameDayAs: date) }
    }

    func addCompletedDate(_ date: Date) {
        if !self.isCompleted(for: date) {
            self.completedDates.append(date)
            self.completedDates = self.completedDates.removingDuplicates() // Видаляємо дублікати
        }
    }



    func removeCompletedDate(_ date: Date) {
        self.completedDates.removeAll(where: { $0.isInSameDay(as: date) } )
    }

    func toggleCompletion(daysAgo: Int) {
        let todayMinusDaysAgo = Date.todayMinusDaysAgo(daysAgo: daysAgo)
        print("Before toggle: \(completedDates)")
        
        if self.isCompleted(for: todayMinusDaysAgo) {
            self.removeCompletedDate(todayMinusDaysAgo)
        } else {
            self.addCompletedDate(todayMinusDaysAgo)
        }

        print("After toggle: \(completedDates)")
    }

    
    func calculateStrengthPercentage(completedDates: [Date]) -> Int {
        let completedDatesWithinPeriod = completedDates.filter { $0.isWithinLastDays(daysAgo: strengthCalculationPeriod) }
        let uniqueCompletedDatesWithinPeriod = completedDatesWithinPeriod.removingDuplicates()
        
        let logNumber = Double(uniqueCompletedDatesWithinPeriod.count + 1)
        let logBase = calculateLogarithmBase(value: Double(strengthCalculationPeriod), result: 100)
        
        let calculatedPercentage = Int(log(logNumber)/log(logBase))
        return min(calculatedPercentage, 100)
    }

    func calculateLogarithmBase(value: Double, result: Double) -> Double {
        return pow(value, 1/result)
    }

    func strengthGainedWithinLastDays(daysAgo: Int) -> Int {
        let habitStrength = calculateStrengthPercentage(completedDates: completedDates)
        let completedDatesWithoutLast30Days = completedDates.filter { $0.isWithinLastDays(daysAgo: daysAgo) == false }
        let habitStrengthWithoutLast30Days = calculateStrengthPercentage(completedDates: completedDatesWithoutLast30Days)
        let strengthGainedInMonth = habitStrength - habitStrengthWithoutLast30Days
        return strengthGainedInMonth
    }

    func completionsWithinLastDays(daysAgo: Int) -> Int {
        completedDates.filter { $0.isWithinLastDays(daysAgo: daysAgo) }.count
    }
}


 
