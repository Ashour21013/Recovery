import Foundation
import Observation

/// ViewModel des Statistik-Screens (MVVM).
///
/// Lädt die Rohdaten über das `RecoveryRepository` und delegiert die
/// Berechnung an den `StatisticsCalculator`. Kennt keine Persistenz- oder
/// UI-Details.
@MainActor
@Observable
final class StatisticsViewModel: ViewModel {

    private(set) var state: ViewState<RecoveryStatistics> = .idle

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
            guard let profile = try await repository.loadProfile() else {
                state = .failed(AppError.notFound)
                return
            }
            let relapses = try await repository.fetchRelapses()
            let journal = try await repository.fetchJournalEntries()
            let triggers = try await repository.fetchTriggers()

            let statistics = StatisticsCalculator.makeStatistics(
                profile: profile,
                relapses: relapses,
                journalEntries: journal,
                triggers: triggers
            )
            state = .loaded(statistics)
        } catch {
            state = .failed(error)
        }
    }
}
