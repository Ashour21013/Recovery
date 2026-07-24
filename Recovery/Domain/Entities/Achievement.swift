import Foundation

/// Ein (ggf. freigeschaltetes) Achievement. Reine Domain-Entität.
struct Achievement: Identifiable, Equatable {
    var id: String { type.rawValue }
    let type: AchievementType
    /// Zeitpunkt der Freischaltung, falls bereits erreicht.
    let unlockedAt: Date?

    var isUnlocked: Bool { unlockedAt != nil }
}
