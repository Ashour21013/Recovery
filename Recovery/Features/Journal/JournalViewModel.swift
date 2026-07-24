import Foundation
import Observation

/// ViewModel des Journal-Screens (MVVM).
///
/// Lädt und verwaltet Journal-Einträge ausschließlich über das
/// `RecoveryRepository`. Kennt keine Persistenzdetails (kein SwiftData).
@MainActor
@Observable
final class JournalViewModel: ViewModel {

    private(set) var state: ViewState<[JournalEntry]> = .idle

    /// Bereits genutzte Trigger-Namen (für Schnellauswahl im Editor).
    private(set) var knownTriggers: [String] = []

    private let repository: RecoveryRepository

    init(repository: RecoveryRepository) {
        self.repository = repository
    }

    func onAppear() async {
        if case .loaded = state { return }
        await load()
    }

    func load() async {
        state = .loading
        do {
            let entries = try await repository.fetchJournalEntries()
            knownTriggers = Self.extractTriggers(from: entries)
            state = .loaded(entries)
        } catch {
            state = .failed(error)
        }
    }

    /// Fügt einen neuen Eintrag hinzu und lädt die Liste neu.
    func addEntry(_ entry: JournalEntry) async {
        do {
            try await repository.addJournalEntry(entry)
            await load()
        } catch {
            state = .failed(error)
        }
    }

    func deleteEntry(id: UUID) async {
        do {
            try await repository.deleteJournalEntry(id: id)
            await load()
        } catch {
            state = .failed(error)
        }
    }

    /// Ermittelt eindeutige, alphabetisch sortierte Trigger-Namen.
    private static func extractTriggers(from entries: [JournalEntry]) -> [String] {
        let names = entries.compactMap { $0.triggerName }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return Array(Set(names)).sorted()
    }
}
