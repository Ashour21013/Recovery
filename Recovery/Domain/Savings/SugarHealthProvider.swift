import Foundation

/// Motivierende Energie-/Wohlbefinden-Meilensteine für Zucker-Verzicht.
///
/// Allgemeine, nicht-medizinische Beobachtungen ohne Heilsversprechen.
struct SugarHealthProvider: HealthMilestoneProvider {

    private let table: [HealthMilestone] = [
        HealthMilestone(
            dayThreshold: 1,
            title: "Bewusster Genuss",
            detail: "Der erste Tag mit klarer Entscheidung ist geschafft.",
            systemImage: "leaf.fill"
        ),
        HealthMilestone(
            dayThreshold: 3,
            title: "Weniger Heißhunger",
            detail: "Viele bemerken nach wenigen Tagen ausgeglichenere Gelüste.",
            systemImage: "arrow.down.heart.fill"
        ),
        HealthMilestone(
            dayThreshold: 7,
            title: "Stabilere Energie",
            detail: "Ohne Zuckerspitzen fühlt sich der Tag oft gleichmäßiger an.",
            systemImage: "bolt.heart.fill"
        ),
        HealthMilestone(
            dayThreshold: 30,
            title: "Neues Geschmacksgefühl",
            detail: "Nach einigen Wochen schmecken viele natürliche Aromen intensiver.",
            systemImage: "mouth.fill"
        )
    ]

    func milestones(for streakDays: Int) -> [RecoveryGain] {
        latestReached(table, streakDays: streakDays, idPrefix: "sugar")
    }
}
