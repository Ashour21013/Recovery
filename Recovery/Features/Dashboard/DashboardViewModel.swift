import Foundation
import Observation

/// ViewModel des Dashboards (MVVM).
///
/// Hält den Präsentationszustand und lädt die Daten über das
/// `RecoveryRepository`. Es kennt keine Persistenzdetails (kein SwiftData),
/// sondern arbeitet ausschließlich mit Domain-Entities.
@MainActor
@Observable
final class DashboardViewModel: ViewModel {

    /// Ladezustand des Dashboards (Loading-/Error-/Content-Handling).
    private(set) var state: ViewState<DashboardData> = .idle

    /// Steuert die Anzeige des Cravings-Hilfe-Sheets.
    var isShowingCravingHelp = false

    private let repository: RecoveryRepository

    init(repository: RecoveryRepository) {
        self.repository = repository
    }

    /// Lädt die Dashboard-Daten. Idempotent beim ersten Erscheinen.
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
            state = .loaded(makeDashboardData(profile: profile, relapses: relapses, journalCount: journal.count))
        } catch {
            state = .failed(error)
        }
    }

    /// Nutzer meldet akutes Verlangen ("Cravings").
    func handleCravingTapped() {
        isShowingCravingHelp = true
    }

    // MARK: - Aufbereitete Anzeige-Werte

    /// Formatiert den gesparten Betrag gemäß Locale.
    func formattedMoneySaved(for progress: ProgressSummary) -> String {
        progress.moneySaved.formatted(
            .currency(code: progress.currencyCode)
        )
    }

    // MARK: - Ableitung der Anzeige-Daten aus der Domain

    private func makeDashboardData(
        profile: RecoveryProfile,
        relapses: [Relapse],
        journalCount: Int
    ) -> DashboardData {
        let streak = profile.streak()
        return DashboardData(
            habitType: profile.habitType,
            streak: streak,
            quote: QuoteProvider.quote(for: streak.currentDays),
            progress: makeProgress(streak: streak, relapseCount: relapses.count),
            dailyGoal: DailyGoal(
                title: "Heutige Ziele",
                completedTasks: min(journalCount, 3),
                totalTasks: 3
            )
        )
    }

    private func makeProgress(streak: Streak, relapseCount: Int) -> ProgressSummary {
        let milestone = Milestone.next(afterDays: streak.currentDays)
        return ProgressSummary(
            milestoneFraction: milestone.fraction(currentDays: streak.currentDays),
            nextMilestoneTitle: milestone.title,
            moneySaved: Decimal(streak.currentDays) * 7,
            currencyCode: "EUR",
            avoidedCount: max(0, streak.currentDays * 12 - relapseCount)
        )
    }
}
