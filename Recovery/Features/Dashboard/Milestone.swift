import Foundation

/// Meilensteine der Recovery-Reise (in Tagen). Reine Präsentationslogik.
enum Milestone: Int, CaseIterable {
    case day3 = 3
    case week = 7
    case twoWeeks = 14
    case month = 30
    case ninety = 90
    case halfYear = 180
    case year = 365

    var title: String {
        switch self {
        case .day3: "3 Tage"
        case .week: "1 Woche"
        case .twoWeeks: "2 Wochen"
        case .month: "30 Tage"
        case .ninety: "90 Tage"
        case .halfYear: "6 Monate"
        case .year: "1 Jahr"
        }
    }

    /// Nächster noch nicht erreichter Meilenstein.
    static func next(afterDays days: Int) -> Milestone {
        allCases.first { $0.rawValue > days } ?? .year
    }

    /// Vorheriger Meilenstein-Schwellwert (für die Fortschrittsberechnung).
    private var previousThreshold: Int {
        let all = Milestone.allCases
        guard let index = all.firstIndex(of: self), index > 0 else { return 0 }
        return all[index - 1].rawValue
    }

    /// Fortschritt (0–1) innerhalb des aktuellen Meilenstein-Intervalls.
    func fraction(currentDays: Int) -> Double {
        let lower = previousThreshold
        let upper = rawValue
        guard upper > lower else { return 1 }
        let value = Double(currentDays - lower) / Double(upper - lower)
        return min(1, max(0, value))
    }
}
