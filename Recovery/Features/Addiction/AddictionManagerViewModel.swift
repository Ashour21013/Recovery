import Foundation
import Observation

/// ViewModel der Sucht-Verwaltung (MVVM).
///
/// Listet alle getrackten Süchte und ermöglicht Wechseln, Hinzufügen und
/// Löschen. Greift ausschließlich über das `RecoveryRepository` zu.
@MainActor
@Observable
final class AddictionManagerViewModel: ViewModel {

    private(set) var addictions: [AddictionSummary] = []
    private(set) var isLoading = false
    var errorMessage: String?

    /// Steuert die Anzeige des „Sucht hinzufügen"-Flows.
    var isShowingAddFlow = false

    /// Süchte, die noch nicht getrackt werden (für den Hinzufügen-Flow).
    var availableTypesToAdd: [HabitType] {
        let existing = Set(addictions.map(\.habitType))
        return HabitType.allCases.filter { !existing.contains($0) }
    }

    /// Ob weitere Süchte hinzugefügt werden können.
    var canAddMore: Bool { !availableTypesToAdd.isEmpty }

    private let repository: RecoveryRepository

    init(repository: RecoveryRepository) {
        self.repository = repository
    }

    func onAppear() async {
        await reload()
    }

    func reload() async {
        isLoading = true
        defer { isLoading = false }
        do {
            addictions = try await repository.fetchAddictions()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Wechselt die aktive Sucht.
    func switchTo(_ id: UUID) async {
        do {
            try await repository.switchAddiction(to: id)
            await reload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Legt eine neue Sucht an.
    func addAddiction(type: HabitType, reason: String, frequency: HabitFrequency?) async {
        do {
            let profile = RecoveryProfile(
                habitType: type,
                reason: reason,
                frequency: frequency,
                startDate: .now
            )
            try await repository.addAddiction(profile)
            isShowingAddFlow = false
            await reload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Entfernt eine Sucht samt aller zugehörigen Daten.
    func delete(_ id: UUID) async {
        do {
            try await repository.deleteAddiction(id: id)
            await reload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
