import Foundation

/// Auswählbares Ziel (in cleanen Tagen). Reine Domain-Entität ohne UI-Bezug.
enum RecoveryGoal: Int, CaseIterable, Identifiable, Codable {
    case week = 7
    case month = 30
    case ninetyDays = 90
    case year = 365

    var id: Int { rawValue }

    var days: Int { rawValue }

    var title: String {
        switch self {
        case .week: String(localized: "7 Tage")
        case .month: String(localized: "30 Tage")
        case .ninetyDays: String(localized: "90 Tage")
        case .year: String(localized: "365 Tage")
        }
    }

    var systemImage: String {
        switch self {
        case .week: "leaf.fill"
        case .month: "flame.fill"
        case .ninetyDays: "star.fill"
        case .year: "crown.fill"
        }
    }

    /// Fortschritt (0–1) für eine gegebene Anzahl cleaner Tage.
    func fraction(currentDays: Int) -> Double {
        guard days > 0 else { return 1 }
        return min(1.0, max(0.0, Double(currentDays) / Double(days)))
    }

    /// Ob das Ziel mit der aktuellen Streak erreicht wurde.
    func isAchieved(currentDays: Int) -> Bool {
        currentDays >= days
    }

    /// Verbleibende Tage bis zum Ziel (nie negativ).
    func remainingDays(currentDays: Int) -> Int {
        max(0, days - currentDays)
    }
}
