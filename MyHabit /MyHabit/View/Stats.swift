import SwiftUI
import FirebaseAuth

struct Stats: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @FetchRequest(
        entity: Habit.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Habit.dateAdded, ascending: false)],
        predicate: NSPredicate(format: "userID == %@", Auth.auth().currentUser?.uid ?? ""),
        animation: .easeInOut
    ) var habits: FetchedResults<Habit>
    
    @StateObject private var habitModel = HabitsViewModel()
    
    @AppStorage("displayMode") private var displayMode: HistoryView.DisplayModes = .sixMonths
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Stats")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                Spacer()
                Picker("Display mode", selection: $displayMode) {
                    ForEach(HistoryView.DisplayModes.allCases) {
                        Text($0.localizedString())
                    }
                }
                .pickerStyle(.menu)
                .tint(.secondary)
            }
            .padding(.bottom, 10)
            
            ScrollView(habits.isEmpty ? .init() : .vertical, showsIndicators: false) {
                VStack(spacing: 15) {
                    ForEach(habits) { habit in
                        ReportView(
                            dates: habit.completedDates ?? [],
                            color: habit.color ?? "Card-1",
                            title: habit.title ?? "Unnamed Habit",
                            displayMode: displayMode
                        )
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
    }
}
