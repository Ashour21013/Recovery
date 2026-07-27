import Foundation

/// Gesundheits-/Fokus-Meilensteine für Social-Media-Verzicht.
///
/// Vorsichtig formulierte, motivierende Beobachtungen – keine medizinischen
/// Aussagen.
struct SocialMediaHealthProvider: HealthMilestoneProvider {

    private let table: [HealthMilestone] = [
        HealthMilestone(
            dayThreshold: 1,
            title: "Mehr Präsenz",
            detail: "Viele Menschen fühlen sich schon nach kurzer Zeit präsenter im Alltag.",
            systemImage: "person.fill.checkmark"
        ),
        HealthMilestone(
            dayThreshold: 3,
            title: "Mehr Fokus",
            detail: "Ohne ständige Ablenkung fällt konzentriertes Arbeiten oft leichter.",
            systemImage: "scope"
        ),
        HealthMilestone(
            dayThreshold: 7,
            title: "Besserer Schlaf",
            detail: "Weniger Bildschirmzeit am Abend kann zu ruhigeren Nächten beitragen.",
            systemImage: "moon.stars.fill"
        ),
        HealthMilestone(
            dayThreshold: 30,
            title: "Ruhigerer Kopf",
            detail: "Nach einigen Wochen berichten viele von mehr innerer Ruhe.",
            systemImage: "brain.head.profile"
        )
    ]

    func milestones(for streakDays: Int) -> [RecoveryGain] {
        latestReached(table, streakDays: streakDays, idPrefix: "socialMedia")
    }
}
