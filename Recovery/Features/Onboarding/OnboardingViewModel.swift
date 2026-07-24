import Foundation
import Observation

/// ViewModel des Onboarding-Flows (MVVM).
///
/// Hält den gesamten Zustand des Flows: den erfassten `OnboardingDraft`
/// sowie den Navigationspfad. Die Views enthalten keine Geschäftslogik,
/// sondern binden nur an diesen Zustand und rufen dessen Methoden auf.
///
/// Es wird bewusst noch nichts persistiert (Anforderung).
@MainActor
@Observable
final class OnboardingViewModel: ViewModel {

    /// Navigationspfad für den `NavigationStack`.
    var path: [OnboardingStep] = []

    /// Im Flow erfasste Eingaben.
    private(set) var draft = OnboardingDraft()

    /// Signalisiert einen Speicherfehler beim Abschluss.
    var didFailToSave = false

    private let repository: RecoveryRepository

    init(repository: RecoveryRepository) {
        self.repository = repository
    }

    // MARK: - Validierung pro Schritt

    var canContinueFromHabitSelection: Bool { draft.isHabitSelected }
    var canContinueFromFrequency: Bool { draft.isFrequencySelected }

    // MARK: - Eingaben

    func selectHabit(_ habit: HabitType) {
        draft.habitType = habit
    }

    func updateReason(_ reason: String) {
        draft.reason = reason
    }

    func selectFrequency(_ frequency: HabitFrequency) {
        draft.frequency = frequency
    }

    // MARK: - Navigation

    func start() {
        path.append(.habitSelection)
    }

    func goToReason() {
        path.append(.reason)
    }

    func goToFrequency() {
        path.append(.frequency)
    }

    func goToSummary() {
        path.append(.summary)
    }

    /// Schließt das Onboarding ab und persistiert das Profil via Repository.
    /// Gibt `true` zurück, wenn das Speichern erfolgreich war.
    func finish() async -> Bool {
        guard let habitType = draft.habitType else { return false }
        let profile = RecoveryProfile(
            habitType: habitType,
            reason: draft.reason,
            frequency: draft.frequency,
            startDate: .now
        )
        do {
            try await repository.createProfile(profile)
            path.removeAll()
            return true
        } catch {
            didFailToSave = true
            return false
        }
    }
}
