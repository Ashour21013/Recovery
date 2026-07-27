import Foundation

/// Leichtgewichtige Zusammenfassung einer getrackten Sucht.
///
/// Wird für Auswahl-/Verwaltungsansichten (Switcher, Manager) genutzt, ohne
/// das vollständige Profil samt Beziehungen laden zu müssen.
struct AddictionSummary: Equatable, Identifiable {
    let id: UUID
    let habitType: HabitType
    let currentStreakDays: Int
    let bestStreakDays: Int
    /// Ob diese Sucht aktuell die aktive (im Dashboard angezeigte) ist.
    let isActive: Bool

    var title: String { habitType.title }
    var emoji: String { habitType.emoji }
}
