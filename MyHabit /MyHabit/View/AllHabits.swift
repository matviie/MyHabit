import SwiftUI
import CoreData
import FirebaseAuth

struct AllHabits: View {
    
    @Environment(\.managedObjectContext) private var context
    
    // MARK: - Запит для отримання списку звичок із Core Data
    @FetchRequest(
        entity: Habit.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Habit.dateAdded, ascending: false)],
        predicate: NSPredicate(format: "userID == %@", Auth.auth().currentUser?.uid ?? ""),
        animation: .easeInOut
    ) var habits: FetchedResults<Habit>
    
    // MARK: - Спостережуваний об'єкт моделі звичок
    @StateObject private var habitModel = HabitsViewModel()
    
    
    var body: some View {
        VStack(spacing: 0) {
            Text("All Habits")
                .font(.title2.bold())
                .frame(maxWidth: .infinity)
                .padding(.bottom, 10)
            
            // MARK: - Календар поточного тижня
            CurrentWeekView()
                .padding(.bottom, 20)
            
            // MARK: - Список звичок або порожній вигляд із кнопкою додавання
            ScrollView(habits.isEmpty ? .init() : .vertical, showsIndicators: false) {
                VStack(spacing: 15) {
                    ForEach(habits) { habit in
                        HabitCardView(habit: habit, habitModel: habitModel) // Відображення кожної звички як карточки
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
                habitModel.addNewHabit.toggle()
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
        
        // MARK: - Вікно додавання нової звички
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
}

#Preview {
    AllHabits()
}
