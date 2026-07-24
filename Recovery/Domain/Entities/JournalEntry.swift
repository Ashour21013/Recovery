import Foundation

/// Ein Journal-Eintrag des Nutzers. Reine Domain-Entität ohne UI-Bezug.
struct JournalEntry: Equatable, Identifiable {
    let id: UUID
    var date: Date
    var text: String
    /// Optionale Stimmung von 1 (sehr schlecht) bis 5 (sehr gut).
    var mood: Int?

    init(id: UUID = UUID(), date: Date = .now, text: String, mood: Int? = nil) {
        self.id = id
        self.date = date
        self.text = text
        self.mood = mood
    }
}
