import Foundation

/// Die einzelnen Schritte des Onboarding-Flows.
/// Dient als Wert für den `NavigationStack`-Pfad.
enum OnboardingStep: Hashable {
    case habitSelection
    case reason
    case frequency
    case summary
}
