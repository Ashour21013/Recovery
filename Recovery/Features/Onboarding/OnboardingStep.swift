import Foundation

/// Die einzelnen Schritte des Onboarding-Flows.
/// Dient als Wert für den `NavigationStack`-Pfad.
enum OnboardingStep: Hashable, CaseIterable {
    case habitSelection
    case reason
    case frequency
    case summary

    /// Position dieses Schritts (1-basiert) innerhalb der inhaltlichen Schritte.
    var index: Int {
        switch self {
        case .habitSelection: 1
        case .reason: 2
        case .frequency: 3
        case .summary: 4
        }
    }

    /// Gesamtzahl der inhaltlichen Schritte (ohne Willkommens-Screen).
    static var total: Int { allCases.count }

    /// Fortschritt (0–1) für die Progress-Bar.
    var progress: Double { Double(index) / Double(OnboardingStep.total) }
}
