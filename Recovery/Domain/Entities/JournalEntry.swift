import Foundation

/// Ein Journal-Eintrag des Nutzers. Reine Domain-Entität ohne UI-Bezug.
struct JournalEntry: Equatable, Identifiable {
    let id: UUID
    var date: Date
    var text: String
    /// Optionale Stimmung von 1 (sehr schlecht) bis 5 (sehr gut).
    var mood: Int?
    /// Optionaler Name eines Triggers, der an diesem Tag relevant war.
    var triggerName: String?

    init(
        id: UUID = UUID(),
        date: Date = .now,
        text: String,
        mood: Int? = nil,
        triggerName: String? = nil
    ) {
        self.id = id
        self.date = date
        self.text = text
        self.mood = mood
        self.triggerName = triggerName
    }

    /// Typsicherer Zugriff auf die Stimmung.
    var moodValue: Mood? {
        get { mood.flatMap(Mood.init(rawValue:)) }
        set { mood = newValue?.rawValue }
    }
}
