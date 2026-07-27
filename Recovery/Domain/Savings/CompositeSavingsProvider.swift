import Foundation

/// Adapter: macht einen `HealthMilestoneProvider` als `SavingsMetricProvider`
/// nutzbar, sodass Gesundheits-Meilensteine im selben Gain-System auftauchen.
struct HealthSavingsAdapter: SavingsMetricProvider {

    private let health: HealthMilestoneProvider

    init(_ health: HealthMilestoneProvider) {
        self.health = health
    }

    func gains(
        for habitType: HabitType,
        streakDays: Int,
        metrics: AddictionMetrics
    ) -> [RecoveryGain] {
        health.milestones(for: streakDays)
    }
}

/// Kombiniert mehrere `SavingsMetricProvider` zu einem (Composite-Pattern).
/// Die Reihenfolge der Gains entspricht der Provider-Reihenfolge.
struct CompositeSavingsProvider: SavingsMetricProvider {

    private let providers: [SavingsMetricProvider]

    init(_ providers: [SavingsMetricProvider]) {
        self.providers = providers
    }

    func gains(
        for habitType: HabitType,
        streakDays: Int,
        metrics: AddictionMetrics
    ) -> [RecoveryGain] {
        providers.flatMap {
            $0.gains(for: habitType, streakDays: streakDays, metrics: metrics)
        }
    }
}
