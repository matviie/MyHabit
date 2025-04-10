import SwiftUI


enum HabitColor: String, CaseIterable {
    case red = "Card-1"
    case yellow = "Card-2"
    case pink = "Card-3"
    case purple = "Card-4"
    case blue = "Card-5"
    case green = "Card-6"
    
    var color: Color {
        switch self {
        case .red:
            return Color.red
        case .green:
            return Color.green
        case .blue:
            return Color.blue
        case .yellow:
            return Color.yellow
        case .pink:
            return Color.pink
        case .purple:
            return Color.purple
        }
    }
}
