import SwiftUI

struct HistoryView: View {
    
    enum DisplayModes: String, Identifiable, CaseIterable {
        var id: Self { self }
        case sixMonths = "Six months"
        case oneYear = "One year"
        
        func localizedString() -> LocalizedStringKey {
            LocalizedStringKey(self.rawValue)
        }
    }
    
    var dates: [Date]
    var color: String
    var title: String
    var displayMode: DisplayModes

    private let rows: Int = 7
    private var columns: Int { getNumberOfColumns() }
    private var spacing: CGFloat { getSpacing() }
    private var cornerRadius: CGFloat { getCornerRadius() }
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .font(.caption.bold())
            Spacer()
            HStack(spacing: spacing) {
                ForEach(0..<columns, id: \.self) { column in
                    VStack(spacing: spacing) {
                        ForEach(0..<rows) { row in
                            let index = getIndexForCell(column: column, row: row)
                            let daysShiftOffset = calculateDaysShiftOffset()
                            let shiftedIndex = index - daysShiftOffset
                            let color = getColorForCell(index: shiftedIndex)
                            
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(color)
                                .aspectRatio(1.0, contentMode: .fit)
                        }
                    }
                }
            }
        }
    }
    
    func getColorForCell(index: Int) -> Color {
        let date = getDateForCell(numberOfDaysAgo: index)
        
        if isDayAfterToday(date: date) {
            return .clear
        } else {
            return isDateCompleted(date) ? Color(color) : .TFBG
        }
    }
    
    func isDayAfterToday(date: Date) -> Bool {
        return Calendar.current.compare(Date.now, to: date, toGranularity: .day) == .orderedAscending
    }
    
    func getDateForCell(numberOfDaysAgo: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: -numberOfDaysAgo, to: Date.now)!
    }
    
    func calculateDaysShiftOffset() -> Int {
        guard rows == 7 else { return 0 }
        let today = Date.now
        let nextSunday = today.next(.sunday)
        return nextSunday.days(from: today)
    }
    
    func getIndexForCell(column: Int, row: Int) -> Int {
        let index = (rows * column) + row
        let cellCount = columns * rows
        return (cellCount - index) - 1
    }
    
    func isDateCompleted(_ habitDate: Date) -> Bool {
        return dates.contains { $0.isInSameDay(as: habitDate) }
    }
    
    func getNumberOfColumns() -> Int {
        switch displayMode {
        case .sixMonths:
            return Int(365 / 2 / rows)
        case .oneYear:
            return Int(365 / rows)
        }
    }
    
    func getSpacing() -> CGFloat {
        return displayMode == .sixMonths ? 2.5 : 1
    }
    
    func getCornerRadius() -> CGFloat {
        return 2
    }
}
