import SwiftUI

struct CalendarView: UIViewRepresentable {
    
    let dateInterval: DateInterval
    @Binding var completedDates: [Date]
    var color: String
    
    func makeUIView(context: Context) -> UICalendarView {
        let calendarView = UICalendarView()
        calendarView.tintColor = UIColor(Color(color))
        calendarView.calendar = Calendar(identifier: .gregorian)
        calendarView.calendar.firstWeekday = 2
        calendarView.availableDateRange = dateInterval
        
        let dateSelection = UICalendarSelectionMultiDate(delegate: context.coordinator)
        dateSelection.setSelectedDates(
            completedDates.map { Calendar.current.dateComponents([.year, .month, .day], from: $0) },
            animated: true
        )
        calendarView.selectionBehavior = dateSelection
        return calendarView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, completedDates: $completedDates, color: color)
    }
    
    func updateUIView(_ uiView: UICalendarView, context: Context) {
        let dateSelection = UICalendarSelectionMultiDate(delegate: context.coordinator)
        dateSelection.setSelectedDates(
            completedDates.map { Calendar.current.dateComponents([.year, .month, .day], from: $0) },
            animated: true
        )
        uiView.selectionBehavior = dateSelection
        uiView.tintColor = UIColor(Color(color))
    }
    
    class Coordinator: NSObject, UICalendarSelectionMultiDateDelegate {
        var parent: CalendarView
        @Binding var completedDates: [Date]
        var color: String
        
        init(parent: CalendarView, completedDates: Binding<[Date]>, color: String) {
            self.parent = parent
            self._completedDates = completedDates
            self.color = color
        }
        
        func multiDateSelection(_ selection: UICalendarSelectionMultiDate, didSelectDate dateComponents: DateComponents) {
            if let date = Calendar.current.date(from: dateComponents) {
                completedDates.append(date)
                print("Date added. Updated completedDates: \(formatDates(completedDates))")
            }
        }
        
        func multiDateSelection(_ selection: UICalendarSelectionMultiDate, didDeselectDate dateComponents: DateComponents) {
            if let date = Calendar.current.date(from: dateComponents) {
                completedDates.removeAll { Calendar.current.isDate($0, inSameDayAs: date) }
                print("Date removed. Updated completedDates: \(formatDates(completedDates))")
            }
        }
        
        func multiDateSelection(_ selection: UICalendarSelectionMultiDate, canSelectDate dateComponents: DateComponents) -> Bool {
            return true
        }
        
        private func formatDates(_ dates: [Date]) -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            
            let formattedDates = dates.map { formatter.string(from: $0) }
            return formattedDates.joined(separator: ", ")
        }
    }
}
