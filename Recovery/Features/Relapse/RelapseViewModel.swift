import Foundation
import Observation

/// ViewModel des Relapse-Flows (MVVM).
///
/// Verwaltet die Eingaben (Datum, Verlangen, Trigger, Notiz), lädt die
/// bereits bekannten Trigger zur Mehrfachauswahl und speichert den Rückfall
/// über das `RecoveryRepository`. Kennt keine Persistenz- oder UI-Details.
@MainActor
@Observable
final class RelapseViewModel: ViewModel {

    // MARK: - Eingaben

    var date: Date = .now
    var cravingIntensity: Int = 5
    var note: String = ""
    /// Aktuell ausgewählte Trigger-Namen (Mehrfachauswahl).
    private(set) var selectedTriggers: Set<String> = []
    /// Vom Nutzer neu hinzugefügter Trigger-Name.
    var newTriggerName: String = ""

    /// Vorschläge aus bereits bekannten Triggern (Journal + Trigger-Liste).
    private(set) var suggestedTriggers: [String] = []

    /// Signalisiert einen erfolgreichen Speichervorgang.
    private(set) var didSave = false
    /// Signalisiert einen Speicherfehler.
    var didFail = false

    private let repository: RecoveryRepository

    init(repository: RecoveryRepository) {
        self.repository = repository
    }

    // MARK: - Laden der Vorschläge

    func onAppear() async {
        guard suggestedTriggers.isEmpty else { return }
        await loadSuggestions()
    }

    private func loadSuggestions() async {
        do {
            let triggers = try await repository.fetchTriggers()
            let journal = try await repository.fetchJournalEntries()
            let fromJournal = journal.compactMap { $0.triggerName }
            let names = triggers.map(\.name) + fromJournal
            suggestedTriggers = Self.uniqueSorted(names)
        } catch {
            suggestedTriggers = []
        }
    }

    // MARK: - Trigger-Auswahl

    func isSelected(_ name: String) -> Bool {
        selectedTriggers.contains(name)
    }

    func toggleTrigger(_ name: String) {
        if selectedTriggers.contains(name) {
            selectedTriggers.remove(name)
        } else {
            selectedTriggers.insert(name)
        }
    }

    /// Fügt einen frei eingegebenen Trigger hinzu und wählt ihn aus.
    func addCustomTrigger() {
        let trimmed = newTriggerName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if !suggestedTriggers.contains(trimmed) {
            suggestedTriggers.append(trimmed)
            suggestedTriggers = Self.uniqueSorted(suggestedTriggers)
        }
        selectedTriggers.insert(trimmed)
        newTriggerName = ""
    }

    // MARK: - Speichern

    func save() async {
        let relapse = Relapse(
            date: date,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            cravingIntensity: cravingIntensity,
            triggerNames: Array(selectedTriggers).sorted()
        )
        do {
            try await repository.recordRelapse(relapse)
            didSave = true
        } catch {
            didFail = true
        }
    }

    // MARK: - Helpers

    private static func uniqueSorted(_ names: [String]) -> [String] {
        let cleaned = names
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return Array(Set(cleaned)).sorted()
    }
}
