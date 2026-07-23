import Foundation

/// Sammelt die im Onboarding erfassten Eingaben.
///
/// Bewusst ein reiner Entwurf (Draft) im Speicher – es findet noch
/// keine Persistierung statt. Wird später in eine Domain-Entität und
/// anschließend in ein SwiftData-Modell überführt.
struct OnboardingDraft: Equatable {
    var habitType: HabitType?
    var reason: String = ""
    var frequency: HabitFrequency?

    var isHabitSelected: Bool { habitType != nil }
    var isFrequencySelected: Bool { frequency != nil }
}
