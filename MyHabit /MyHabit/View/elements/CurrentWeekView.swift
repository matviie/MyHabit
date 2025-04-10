import SwiftUI

struct CurrentWeekView: View {
    
    var body: some View {
        
        let calendar = Calendar.current
        let symbols = calendar.shortWeekdaySymbols
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        
        HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { index in
                let currentDate = calendar.date(byAdding: .day, value: index, to: startOfWeek)!
                let isToday = calendar.isDate(currentDate, inSameDayAs: Date())
                
                VStack(spacing: 6) {
                    // Скорочена назва дня тижня
                    Text(symbols[calendar.component(.weekday, from: currentDate) - 1].prefix(3))
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    // Відображення дати та підсвічування сьогоднішнього дня
                    Text(getDate(date: currentDate))
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                        .padding(8)
                        .background {
                            Circle()
                                .fill(isToday ? Color("TFBG") : Color.gray.opacity(0.2))
                                .opacity(isToday ? 1 : 0.5)
                        }
                        .foregroundColor(isToday ? .white : .gray)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    // MARK: - Форматування дати
    func getDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd" // Формат для відображення лише дня місяця
        
        return formatter.string(from: date)
    }
}

#Preview {
    CurrentWeekView()
}
