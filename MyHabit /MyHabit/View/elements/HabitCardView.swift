import SwiftUI


struct HabitCardView: View {
    
    var habit: Habit
    @StateObject var habitModel: HabitsViewModel
    
    var body: some View {
        let color = Color(habit.color ?? "Card-1")
        HStack {
            VStack {
                HStack {
                    Text(habit.title ?? "")
                        .font(.callout)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    
                    Image(systemName: "bell.badge.fill")
                        .font(.callout)
                        .foregroundColor(color)
                        .scaleEffect(0.9)
                        .opacity(habit.isRemainderOn ? 1 : 0) // Відображається, якщо нагадування увімкнене
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                let count = habit.weekDays?.count ?? 0
                Text(count == 7 ? "Everyday" : "\(count) times a week")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(alignment: .leading)
            
            Spacer()
            
            completionCheckbox(color: color, habit: habit)
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 6)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color("TFBG").opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(color, lineWidth: 2)
                )
        }
        
        .onTapGesture {
            // MARK: - Відкриття форми редагування звички
            habitModel.editHabit = habit
            habitModel.restoreEditData()
            habitModel.editHabitFlag.toggle()
        }
    }
    
    
    // MARK: - Чекбокс для відмітки виконання звички сьогодні
    func completionCheckbox(color: Color, habit: Habit) -> some View {
        Button {
            toggleCompletionForToday(habit: habit) // Передаємо конкретну звичку
        } label: {
            // Визначення, чи звичка вже виконана сьогодні
            let isCompleted = habit.completedDates?.contains {
                Calendar.current.isDate($0, inSameDayAs: Date())
            } ?? false
            
            Image(systemName: isCompleted ? "checkmark.square.fill" : "square")
            // Відображення відповідної іконки
                .resizable()
                .foregroundColor(color) // Колір іконки залежить від теми
                .frame(width: 30, height: 30)
                .padding(isCompleted ? 9 : 10)
                .aspectRatio(contentMode: .fit) // Збереження пропорцій іконки
                .contentShape(Rectangle()) // Зона для взаємодії у формі прямокутника
        }
    }
    
    // MARK: - Функція для відмітки виконання звички на поточний день
    func toggleCompletionForToday(habit: Habit) {
        print("----------------------------------")
        let today = Calendar.current.startOfDay(for: Date())
        
        if habit.completedDates == nil {
            habit.completedDates = []
        }
        
        var updatedDates = habit.completedDates ?? []
        
        if let index = updatedDates.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: today) }) {
            updatedDates.remove(at: index) // Видаляємо, якщо вже є
        } else {
            updatedDates.append(today) // Додаємо поточний день
        }
        
        habit.completedDates = updatedDates
        
        let localDate = Date().addingTimeInterval(TimeInterval(TimeZone.current.secondsFromGMT(for: Date())))
        updatedDates.append(localDate)
        
        print("Дати перед збереженням: \(updatedDates)")
        
        
        if habit.managedObjectContext == nil {
            print("⚠️ Помилка: managedObjectContext у Habit дорівнює nil!")
        } else {
            print("✅ managedObjectContext доступний")
        }
        
        
        // Збереження змін у Core Data
        do {
            print("Оновлені дати: \(habit.completedDates ?? [])")
            try habit.managedObjectContext?.save()
            print("Дані збережено!")
        } catch {
            print("Помилка збереження: \(error.localizedDescription)")
        }
    }
}
