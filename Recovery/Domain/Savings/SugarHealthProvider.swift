import Foundation

/// Motivierende Energie-/Wohlbefinden-Meilensteine für Zucker-Verzicht.
///
/// Allgemeine, nicht-medizinische Beobachtungen ohne Heilsversprechen.
struct SugarHealthProvider: HealthMilestoneProvider {

    private let table: [HealthMilestone] = [
        HealthMilestone(
            dayThreshold: 1,
            title: String(localized: "Bewusster Genuss"),
            detail: String(localized: "Der erste Tag mit klarer Entscheidung ist geschafft."),
            systemImage: "leaf.fill"
        ),
        HealthMilestone(
            dayThreshold: 3,
            title: String(localized: "Weniger Heißhunger"),
            detail: String(localized: "Viele bemerken nach wenigen Tagen ausgeglichenere Gelüste."),
            systemImage: "arrow.down.heart.fill"
        ),
        HealthMilestone(
            dayThreshold: 7,
            title: String(localized: "Stabilere Energie"),
            detail: String(localized: "Ohne Zuckerspitzen fühlt sich der Tag oft gleichmäßiger an."),
            systemImage: "bolt.heart.fill"
        ),
        HealthMilestone(
            dayThreshold: 30,
            title: String(localized: "Neues Geschmacksgefühl"),
            detail: String(localized: "Nach einigen Wochen schmecken viele natürliche Aromen intensiver."),
            systemImage: "mouth.fill"
        )
    ]

    func milestones(for streakDays: Int) -> [RecoveryGain] {
        latestReached(table, streakDays: streakDays, idPrefix: "sugar")
    }
}
