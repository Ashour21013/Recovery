import Foundation

/// Liefert streak-abhängige, motivierende Gesundheits-Meilensteine.
///
/// Bewusst **nicht-medizinisch**: allgemeine, vorsichtig formulierte
/// Beobachtungen ohne Heilsversprechen (Apple-Guideline-konform). Ergänzt das
/// `SavingsMetricProvider`-System um `RecoveryGain`s vom Typ `.health`.
protocol HealthMilestoneProvider {

    /// Motivierende Meilensteine für die aktuelle Streak-Dauer.
    /// Liefert i. d. R. den zuletzt erreichten Meilenstein.
    func milestones(for streakDays: Int) -> [RecoveryGain]
}

/// Ein einzelner, motivierender Meilenstein an einer Streak-Schwelle.
struct HealthMilestone {
    let dayThreshold: Int
    let title: String
    let detail: String
    let systemImage: String
}

extension HealthMilestoneProvider {

    /// Wählt aus einer sortierten Tabelle den höchsten bereits erreichten
    /// Meilenstein und mappt ihn auf einen `RecoveryGain`.
    func latestReached(_ table: [HealthMilestone], streakDays: Int, idPrefix: String) -> [RecoveryGain] {
        guard let milestone = table
            .filter({ streakDays >= $0.dayThreshold })
            .max(by: { $0.dayThreshold < $1.dayThreshold })
        else { return [] }

        return [
            RecoveryGain(
                id: "\(idPrefix).health.\(milestone.dayThreshold)",
                kind: .health,
                value: 0,
                unit: "",
                title: milestone.title,
                detail: milestone.detail,
                systemImage: milestone.systemImage
            )
        ]
    }
}
