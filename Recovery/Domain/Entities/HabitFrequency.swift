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
}
