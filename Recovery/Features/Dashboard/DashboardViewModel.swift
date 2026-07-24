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

    /// Steuert die Anzeige des Ziel-Auswahl-Sheets.
    var isShowingGoalPicker = false

    /// Gerade erreichtes Ziel für die Erfolgsmeldung (falls vorhanden).
    private(set) var achievedGoal: RecoveryGoal?

    private let repository: RecoveryRepository

    /// Merkt sich (gerätelokal), welche Ziele bereits gefeiert wurden,
    /// damit die Erfolgsmeldung pro Ziel nur einmal erscheint.
    private let celebratedKey = "recovery.celebratedGoals"

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
            let plan = try await repository.fetchPlan(for: .now)
            let data = makeDashboardData(
                profile: profile,
                relapses: relapses,
                journalCount: journal.count,
                plan: plan
            )
            state = .loaded(data)
            checkForAchievement(data.goalProgress)
        } catch {
            state = .failed(error)
        }
    }

    /// Nutzer meldet akutes Verlangen ("Cravings").
    func handleCravingTapped() {
        isShowingCravingHelp = true
    }

    // MARK: - Recovery-Plan

    /// Schaltet eine Plan-Aufgabe um und aktualisiert den Fortschritt optimistisch.
    func toggleTask(_ type: RecoveryTaskType) async {
        guard case let .loaded(data) = state,
              let index = data.plan.tasks.firstIndex(where: { $0.type == type }) else { return }

        let newValue = !data.plan.tasks[index].isCompleted

        // Optimistisches UI-Update für ein direktes, flüssiges Gefühl.
        var updated = data
        updated.plan.tasks[index].isCompleted = newValue
        state = .loaded(updated)

        do {
            try await repository.setTaskCompletion(type, on: .now, isCompleted: newValue)
        } catch {
            // Bei Fehler den ursprünglichen Zustand wiederherstellen.
            state = .loaded(data)
        }
    }

    // MARK: - Ziele

    func presentGoalPicker() {
        isShowingGoalPicker = true
    }

    /// Setzt das gewählte Ziel und lädt das Dashboard neu.
    func setGoal(_ goal: RecoveryGoal?) async {
        do {
            try await repository.updateGoal(goal)
            isShowingGoalPicker = false
            await load()
        } catch {
            state = .failed(error)
        }
    }

    /// Bestätigt die Erfolgsmeldung und blendet sie aus.
    func dismissAchievement() {
        if let goal = achievedGoal {
            markCelebrated(goal)
        }
        achievedGoal = nil
    }

    /// Prüft, ob ein Ziel neu erreicht wurde und noch nicht gefeiert wurde.
    private func checkForAchievement(_ progress: GoalProgress?) {
        guard let progress, progress.isAchieved, !hasCelebrated(progress.goal) else {
            return
        }
        achievedGoal = progress.goal
    }

    private func hasCelebrated(_ goal: RecoveryGoal) -> Bool {
        celebratedGoals().contains(goal.rawValue)
    }

    private func markCelebrated(_ goal: RecoveryGoal) {
        var ids = celebratedGoals()
        ids.insert(goal.rawValue)
        UserDefaults.standard.set(Array(ids), forKey: celebratedKey)
    }

    private func celebratedGoals() -> Set<Int> {
        let array = UserDefaults.standard.array(forKey: celebratedKey) as? [Int] ?? []
        return Set(array)
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
        journalCount: Int,
        plan: RecoveryPlan
    ) -> DashboardData {
        let streak = profile.streak()
        let goalProgress = profile.goal.map {
            GoalProgress(goal: $0, currentDays: streak.currentDays)
        }
        return DashboardData(
            habitType: profile.habitType,
            streak: streak,
            quote: QuoteProvider.quote(for: streak.currentDays),
            progress: makeProgress(streak: streak, relapseCount: relapses.count),
            dailyGoal: DailyGoal(
                title: "Heutige Ziele",
                completedTasks: plan.completedCount,
                totalTasks: plan.totalCount
            ),
            goalProgress: goalProgress,
            plan: plan
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
