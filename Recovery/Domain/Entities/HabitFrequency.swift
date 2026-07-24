import Foundation

/// Wie häufig die Gewohnheit auftritt. Reine Domain-Entität.
enum HabitFrequency: String, CaseIterable, Identifiable, Hashable {
    case multipleTimesADay
    case daily
    case fewTimesAWeek
    case weekly
    case occasionally

    var id: String { rawValue }

    var title: String {
        switch self {
        case .multipleTimesADay: "Mehrmals täglich"
        case .daily: "Täglich"
        case .fewTimesAWeek: "Mehrmals pro Woche"
        case .weekly: "Wöchentlich"
        case .occasionally: "Gelegentlich"
        }
    }

    /// Symbol zur illustrativen Darstellung im Onboarding.
    var iconName: String {
        switch self {
        case .multipleTimesADay: "clock.badge.exclamationmark"
        case .daily: "sun.max.fill"
        case .fewTimesAWeek: "calendar"
        case .weekly: "calendar.badge.clock"
        case .occasionally: "sparkles"
        }
    }
}
