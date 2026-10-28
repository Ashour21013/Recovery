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
        case .multipleTimesADay: String(localized: "Mehrmals täglich")
        case .daily: String(localized: "Täglich")
        case .fewTimesAWeek: String(localized: "Mehrmals pro Woche")
        case .weekly: String(localized: "Wöchentlich")
        case .occasionally: String(localized: "Gelegentlich")
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
