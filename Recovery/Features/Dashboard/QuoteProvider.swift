import Foundation

/// Liefert einen zur aktuellen Streak passenden Motivationsspruch.
/// Reine Präsentationslogik – keine Persistenz.
enum QuoteProvider {

    private static let quotes: [MotivationalQuote] = [
        MotivationalQuote(text: "Jeder Tag ohne Rückfall ist ein Sieg über dich selbst."),
        MotivationalQuote(text: "Der beste Zeitpunkt anzufangen war gestern. Der zweitbeste ist jetzt."),
        MotivationalQuote(text: "Du bist stärker als deine Gewohnheit."),
        MotivationalQuote(text: "Kleine Schritte jeden Tag führen zu großen Veränderungen."),
        MotivationalQuote(text: "Stolz auf jeden Tag, den du durchgehalten hast.")
    ]

    /// Wählt deterministisch anhand der Tagesanzahl einen Spruch,
    /// sodass er sich pro Tag ändert, aber innerhalb eines Tages stabil bleibt.
    static func quote(for streakDays: Int) -> MotivationalQuote {
        guard !quotes.isEmpty else {
            return MotivationalQuote(text: "Bleib dran.")
        }
        let index = ((streakDays % quotes.count) + quotes.count) % quotes.count
        return quotes[index]
    }
}
