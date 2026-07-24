import Foundation

/// Zentrale Mock-Datenquelle für das Dashboard.
///
/// Wird ausschließlich während der Entwicklung genutzt und später durch
/// echte Use Cases / Repositories ersetzt. Bewusst von der UI getrennt.
enum DashboardMockData {

    static var sample: DashboardData {
        DashboardData(
            habitType: .smoking,
            streak: Streak(
                currentDays: 12,
                bestDays: 21,
                startedAt: Calendar.current.date(byAdding: .day, value: -12, to: .now) ?? .now
            ),
            motivation: MotivationItem(
                id: "mock",
                text: "Du bist stärker als deine Gewohnheit.",
                source: nil,
                origin: .quotes
            ),
            progress: ProgressSummary(
                milestoneFraction: 12.0 / 30.0,
                nextMilestoneTitle: "30 Tage",
                moneySaved: 84,
                currencyCode: "EUR",
                avoidedCount: 144
            ),
            dailyGoal: DailyGoal(
                title: "Heutige Ziele",
                completedTasks: 2,
                totalTasks: 3
            ),
            goalProgress: nil,
            plan: RecoveryPlan(date: .now, tasks: [])
        )
    }
}
