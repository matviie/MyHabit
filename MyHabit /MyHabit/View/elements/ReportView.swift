import SwiftUI

struct ReportView: View {
    var dates: [Date]
    var color: String
    var title: String
    var displayMode: HistoryView.DisplayModes
    

    var body: some View {
        
        VStack(alignment: .leading) {
            HistoryView(dates: dates, color: color, title: title, displayMode: displayMode)
            
            Text("\(strengthPercentage) %")
            Text("Current streak: \(streak)")
            
        }
    }
    
    var strengthCalculationPeriod: Int { 60 }
    
    var strengthPercentage: Int {
        calculateStrengthPercentage(completedDates: dates)
    }
    
    var streak: Int {
        let dates = processDatesForStreakCalculation(dates)
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
    
    func processDatesForStreakCalculation(_ dates: [Date]) -> [Date] {
        let dates = dates.map { Calendar.current.startOfDay(for: $0) }
        let datesWithoutDaysAfterToday = dates.filter { $0 <= Date.now }
        let uniqueDatesWithinPeriod = datesWithoutDaysAfterToday.removingDuplicates()
        let sortedDates = uniqueDatesWithinPeriod.sorted { $0 > $1 }
        return sortedDates
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
    
    
}
