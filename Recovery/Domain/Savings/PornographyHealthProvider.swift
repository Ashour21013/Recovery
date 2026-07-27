import Foundation

/// Motivierende Fokus-/Energie-Meilensteine für Pornografie-Verzicht.
///
/// Bewusst allgemein und nicht-medizinisch formuliert.
struct PornographyHealthProvider: HealthMilestoneProvider {

    private let table: [HealthMilestone] = [
        HealthMilestone(
            dayThreshold: 1,
            title: "Klarer Start",
            detail: "Der erste Schritt ist gemacht – bewusst und selbstbestimmt.",
            systemImage: "sunrise.fill"
        ),
        HealthMilestone(
            dayThreshold: 3,
            title: "Mehr Energie",
            detail: "Viele beschreiben schon früh ein Gefühl von mehr Antrieb.",
            systemImage: "bolt.fill"
        ),
        HealthMilestone(
            dayThreshold: 7,
            title: "Klarerer Kopf",
            detail: "Ohne die Gewohnheit fühlt sich der Alltag oft klarer an.",
            systemImage: "brain.head.profile"
        ),
        HealthMilestone(
            dayThreshold: 30,
            title: "Echte Verbindung",
            detail: "Mehr Raum für echte Nähe und bewusste Beziehungen.",
            systemImage: "heart.fill"
        )
    ]

    func milestones(for streakDays: Int) -> [RecoveryGain] {
        latestReached(table, streakDays: streakDays, idPrefix: "pornography")
    }
}
