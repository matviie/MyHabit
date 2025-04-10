import SwiftUI
import CoreData
import FirebaseAuth

struct Today: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @FetchRequest(
        entity: Habit.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Habit.dateAdded, ascending: false)],
        predicate: NSPredicate(format: "userID == %@", Auth.auth().currentUser?.uid ?? ""),
        animation: .easeInOut
    ) var habits: FetchedResults<Habit>
    
    @StateObject private var habitModel = HabitsViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Today")
                .font(.title2.bold())
                .frame(maxWidth: .infinity)
                .padding(.bottom, 10)
            
            CurrentWeekView()
                .padding(.bottom, 20)
            
            let todayName = getTodayName()
            let todayHabits = habits.filter { $0.weekDays?.contains(todayName) == true }
            
            ScrollView(todayHabits.isEmpty ? .init() : .vertical, showsIndicators: false) {
                VStack(spacing: 15) {
                    if todayHabits.isEmpty {
                        Text("No habits for today 🎉")
                            .foregroundStyle(.gray)
                            .padding()
                    } else {
                        ForEach(todayHabits) { habit in
                            HabitCardView(habit: habit, habitModel: habitModel)
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding()
        .onAppear {
            habitModel.loadHabits(context: context)
        }
        
        // MARK: - Кнопка додавання
        .overlay(alignment: .bottomTrailing) {
            Button(action: {
                habitModel.addNewHabit.toggle() // Відкриваємо AddNewHabit
            }) {
                Image(systemName: "plus")
                    .font(.title)
                    .frame(width: 50, height: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .shadow(radius: 5)
                    .padding()
            }
            .frame(maxWidth: .infinity)
        }
        
        .sheet(isPresented: $habitModel.addNewHabit) {
            habitModel.resetData()
        } content: {
            AddNewHabit()
                .environmentObject(habitModel)
        }
        
        .sheet(isPresented: $habitModel.editHabitFlag) {
            habitModel.resetData()
        } content: {
            EditHabit()
                .environmentObject(habitModel)
        }
    }
    
    // Функція отримання назви поточного дня (наприклад, "Monday")
    func getTodayName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" 
        return formatter.string(from: Date())
    }
}

#Preview {
    ContentView()
}
