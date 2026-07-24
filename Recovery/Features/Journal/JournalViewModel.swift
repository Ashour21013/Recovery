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
}
