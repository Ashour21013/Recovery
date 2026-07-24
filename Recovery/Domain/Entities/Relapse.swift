import Foundation

/// Ein dokumentierter Rückfall. Reine Domain-Entität ohne UI-Bezug.
struct Relapse: Equatable, Identifiable {
    let id: UUID
    var date: Date
    var note: String
    /// Stärke des Verlangens zum Zeitpunkt des Rückfalls (1–10).
    var cravingIntensity: Int
    /// Namen der beteiligten Trigger (Mehrfachauswahl möglich).
    var triggerNames: [String]

    init(
        id: UUID = UUID(),
        date: Date = .now,
        note: String = "",
        cravingIntensity: Int = 5,
        triggerNames: [String] = []
    ) {
        self.id = id
        self.date = date
        self.note = note
        self.cravingIntensity = cravingIntensity
        self.triggerNames = triggerNames
    }
}
