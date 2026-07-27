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

    /// Steuert die Anzeige der Motivationsquellen-Auswahl.
    var isShowingSourcePicker = false

    /// Aktuell gewählte Motivationsquelle (für den Picker).
    private(set) var motivationSource: MotivationSource = .default

    /// Gerade erreichtes Ziel für die Erfolgsmeldung (falls vorhanden).
    private(set) var achievedGoal: RecoveryGoal?

    /// Alle getrackten Süchte (für den Switcher oben im Dashboard).
    private(set) var addictions: [AddictionSummary] = []

    /// Steuert die Anzeige der Sucht-Verwaltung (Hinzufügen/Löschen/Wechseln).
    var isShowingAddictionManager = false

    /// Berechnete Fortschritts-Gewinne der aktiven Sucht (Geld/Zeit/Menge).
    private(set) var gains: [RecoveryGain] = []

    /// Ob für die aktive Sucht bereits Metrik-Eingaben hinterlegt sind.
    private(set) var hasMetrics = false

    /// Steuert die Anzeige des Metrik-Editors ("Werte hinzufügen").
    var isShowingMetricsEditor = false

    private let repository: RecoveryRepository
    private let motivationService: MotivationService
    private let savingsFactory: SavingsMetricProviderFactory

    /// Merkt sich (gerätelokal), welche Ziele bereits gefeiert wurden,
    /// damit die Erfolgsmeldung pro Ziel nur einmal erscheint.
    private let celebratedKey = "recovery.celebratedGoals"

    init(
        repository: RecoveryRepository,
        motivationService: MotivationService,
        savingsFactory: SavingsMetricProviderFactory
    ) {
        self.repository = repository
        self.motivationService = motivationService
        self.savingsFactory = savingsFactory
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
            addictions = try await repository.fetchAddictions()
            motivationSource = profile.motivationSource
            await loadGains(for: profile)
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

    // MARK: - Motivationsquelle

    func presentSourcePicker() {
        isShowingSourcePicker = true
    }

    /// Speichert die gewählte Quelle und lädt das Dashboard neu.
    func setMotivationSource(_ source: MotivationSource) async {
        do {
            try await repository.updateMotivationSource(source)
            motivationSource = source
            isShowingSourcePicker = false
            await load()
        } catch {
            state = .failed(error)
        }
    }

    // MARK: - Süchte (Multi-Addiction)

    /// Öffnet die Sucht-Verwaltung.
    func presentAddictionManager() {
        isShowingAddictionManager = true
    }

    /// Wechselt die aktive Sucht und lädt das Dashboard neu.
    func switchAddiction(to id: UUID) async {
        do {
            try await repository.switchAddiction(to: id)
            await load()
            // Alle übrigen Screens (Journal, Statistik, Erfolge) informieren.
            AddictionChangeBroadcaster.broadcast()
        } catch {
            state = .failed(error)
        }
    }

    /// Wird nach Änderungen in der Verwaltung aufgerufen (Neuladen).
    func addictionsDidChange() async {
        await load()
    }

    // MARK: - Fortschritts-Gewinne (Geld/Zeit/Menge)

    /// Öffnet den Editor zum Erfassen der Metrik-Eingaben.
    func presentMetricsEditor() {
        isShowingMetricsEditor = true
    }

    /// Wird nach dem Speichern im Metrik-Editor aufgerufen (Neuladen).
    func metricsDidChange() async {
        await load()
    }

    /// Berechnet die passenden Gewinne der aktiven Sucht über den per Factory
    /// gewählten Provider (ViewModel kennt nur die Abstraktion).
    private func loadGains(for profile: RecoveryProfile) async {
        let metrics = (try? await repository.fetchMetrics()) ?? .empty
        hasMetrics = metrics.hasAnyInput
        let provider = savingsFactory.provider(for: profile.habitType)
        gains = provider.gains(
            for: profile.habitType,
            streakDays: profile.currentStreakDays(),
            metrics: metrics
        )
    }

    /// Leitet den passenden Motivationskontext aus der aktuellen Situation ab.
    private func motivationContext(streak: Streak, relapses: [Relapse]) -> MotivationContext {
        // Kürzlicher Rückfall (heute oder gestern)?
        if let last = relapses.map(\.date).max() {
            let days = Calendar.current.dateComponents([.day], from: last, to: .now).day ?? .max
            if days <= 1 { return .relapse }
        }
        // Meilenstein exakt erreicht?
        if Milestone.allCases.contains(where: { $0.rawValue == streak.currentDays }) {
            return .milestone
        }
        return .daily
    }

    // MARK: - Recovery-Plan

    /// Steuert die Anzeige des Plan-Editors.
    var isShowingPlanEditor = false

    /// Schaltet eine Plan-Aufgabe um und aktualisiert den Fortschritt optimistisch.
    func toggleTask(_ taskId: String) async {
        guard case let .loaded(data) = state,
              let index = data.plan.tasks.firstIndex(where: { $0.id == taskId }) else { return }

        let newValue = !data.plan.tasks[index].isCompleted

        // Optimistisches UI-Update für ein direktes, flüssiges Gefühl.
        var updated = data
        updated.plan.tasks[index].isCompleted = newValue
        state = .loaded(updated)

        do {
            try await repository.setTaskCompletion(taskId, on: .now, isCompleted: newValue)
        } catch {
            // Bei Fehler den ursprünglichen Zustand wiederherstellen.
            state = .loaded(data)
        }
    }

    /// Öffnet den Editor zum Anpassen des Plans.
    func presentPlanEditor() {
        isShowingPlanEditor = true
    }

    /// Wird nach Änderungen im Plan-Editor aufgerufen, um neu zu laden.
    func planDidChange() async {
        await load()
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
        let context = motivationContext(streak: streak, relapses: relapses)
        let motivation = motivationService.dailyMotivation(
            source: profile.motivationSource,
            context: context
        )
        return DashboardData(
            habitType: profile.habitType,
            streak: streak,
            motivation: motivation,
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
