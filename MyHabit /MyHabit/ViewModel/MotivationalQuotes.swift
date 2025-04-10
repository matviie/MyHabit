import Foundation

enum MotivationalQuotes: String, CaseIterable {
    case quote1 = "Success is the sum of small efforts, repeated every day. 💪"
    case quote2 = "The secret to getting ahead is getting started. 🚀"
    case quote3 = "Discipline is the bridge between goals and accomplishment. 🎯"
    case quote4 = "Good habits are the key to all success. 🔑"
    case quote5 = "What you do today can improve all your tomorrows. 🌅"
    case quote6 = "The habit of persistence is the habit of victory. 🏆"
    case quote7 = "Your habits will determine your future. 🔮"
    case quote8 = "Discipline is choosing between what you want now and what you want most. ⏳"
    case quote9 = "The future depends on what you do today. 🕰️"
    case quote10 = "A small habit can make a big difference. 🌱"

    static func randomQuote() -> String {
        let randomIndex = Int.random(in: 0..<MotivationalQuotes.allCases.count)
        return MotivationalQuotes.allCases[randomIndex].rawValue
    }
}
