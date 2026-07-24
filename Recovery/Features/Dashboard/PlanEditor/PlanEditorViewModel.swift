import Foundation
import Observation

/// ViewModel des Plan-Editors (MVVM).
///
/// Verwaltet die anpassbare Plan-Definition: aktuelle Aufgaben, verfügbare
/// Vorschläge und das Hinzufügen eigener Übungen. Arbeitet ausschließlich über
/// das `RecoveryRepository` und kennt keine Persistenzdetails.
@MainActor
@Observable
final class PlanEditorViewModel: ViewModel {

    private(set) var tasks: [PlanTask] = []

    /// Eingaben für eine neue, selbst vorgeschlagene Übung.
    var newTitle: String = ""
    var newSubtitle: String = ""

    var errorMessage: String?

    private let repository: RecoveryRepository

    init(repository: RecoveryRepository) {
        self.repository = repository
    }

    /// Noch nicht im Plan enthaltene Standard-Vorschläge.
    var availableSuggestions: [RecoveryTaskType] {
        let currentIds = Set(tasks.map(\.id))
        return RecoveryTaskType.suggestions.filter { !currentIds.contains($0.rawValue) }
    }

    var canAddCustom: Bool {
        !newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func onAppear() async {
        await reload()
    }

    func reload() async {
        do {
            tasks = try await repository.fetchPlanTasks()
        } catch {
            errorMessage = "Der Plan konnte nicht geladen werden."
        }
    }

    /// Übernimmt einen Standard-Vorschlag in den Plan.
    func addSuggestion(_ type: RecoveryTaskType) async {
        await add(PlanTask(type))
    }

    /// Fügt die eingegebene eigene Übung hinzu.
    func addCustom() async {
        let title = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        let subtitle = newSubtitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let task = PlanTask.custom(
            title: title,
            subtitle: subtitle.isEmpty ? "Eigene Übung" : subtitle,
            systemImage: "star.fill"
        )
        await add(task)
        newTitle = ""
        newSubtitle = ""
    }

    /// Entfernt eine Aufgabe aus dem Plan.
    func remove(_ task: PlanTask) async {
        do {
            try await repository.removePlanTask(id: task.id)
            await reload()
        } catch {
            errorMessage = "Die Aufgabe konnte nicht entfernt werden."
        }
    }

    func remove(at offsets: IndexSet) async {
        let toRemove = offsets.map { tasks[$0] }
        for task in toRemove {
            await remove(task)
        }
    }

    // MARK: - Private

    private func add(_ task: PlanTask) async {
        do {
            try await repository.addPlanTask(task)
            await reload()
        } catch {
            errorMessage = "Die Aufgabe konnte nicht hinzugefügt werden."
        }
    }
}
