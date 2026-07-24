import Foundation
import Observation

/// ViewModel des Achievements-Screens (MVVM).
///
/// Lädt alle Achievements zur Anzeige und wertet den aktuellen Fortschritt
/// aus, um neue Freischaltungen zu erkennen. Baut den `AchievementContext`
/// aus den Repository-Daten. Kennt keine Persistenzdetails.
@MainActor
@Observable
final class AchievementsViewModel: ViewModel {

    private(set) var achievements: [Achievement] = []
    /// Neu freigeschaltete Achievements für die Animation.
    private(set) var newlyUnlocked: [Achievement] = []

    var unlockedCount: Int { achievements.filter(\.isUnlocked).count }

    private let service: AchievementService
    private let repository: RecoveryRepository
    private let cravingCounter: CravingSessionCounter

    init(
        service: AchievementService,
        repository: RecoveryRepository,
        cravingCounter: CravingSessionCounter
    ) {
        self.service = service
        self.repository = repository
        self.cravingCounter = cravingCounter
    }

    /// Lädt die Liste und wertet gleichzeitig neue Freischaltungen aus.
    func onAppear() async {
        await evaluateAndReload()
    }

    func evaluateAndReload() async {
        if let context = await makeContext() {
            newlyUnlocked = await service.evaluate(context)
        }
        achievements = await service.allAchievements()
    }

    /// Bestätigt die Freischalt-Animation.
    func dismissUnlockAnimation() {
        newlyUnlocked = []
    }

    // MARK: - Kontext-Aufbau

    private func makeContext() async -> AchievementContext? {
        guard let profile = try? await repository.loadProfile() else { return nil }
        let journal = (try? await repository.fetchJournalEntries()) ?? []
        let relapses = (try? await repository.fetchRelapses()) ?? []

        let streak = profile.streak()
        let hours = Calendar.current.dateComponents(
            [.hour],
            from: profile.startDate,
            to: .now
        ).hour ?? 0

        let daysSinceLastRelapse = relapses
            .map { Calendar.current.dateComponents([.day], from: $0.date, to: .now).day ?? 0 }
            .min()

        return AchievementContext(
            currentStreakDays: streak.currentDays,
            hoursSinceStart: max(0, hours),
            journalCount: journal.count,
            completedCravingSessions: cravingCounter.completedCount,
            relapseCount: relapses.count,
            daysSinceLastRelapse: daysSinceLastRelapse
        )
    }
}
