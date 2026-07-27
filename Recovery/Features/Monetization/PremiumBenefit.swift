import Foundation

/// Ein einzelner Premium-Vorteil für die Paywall-Vorteilsliste.
struct PremiumBenefit: Identifiable {
    let id = UUID()
    let systemImage: String
    let title: String
    let subtitle: String

    /// Kuratierte Standard-Vorteile.
    static let all: [PremiumBenefit] = [
        PremiumBenefit(
            systemImage: "infinity",
            title: "Unbegrenzter Zugang",
            subtitle: "Alle Funktionen ohne Einschränkungen nutzen."
        ),
        PremiumBenefit(
            systemImage: "chart.line.uptrend.xyaxis",
            title: "Erweiterte Statistiken",
            subtitle: "Tiefergehende Einblicke in deinen Fortschritt."
        ),
        PremiumBenefit(
            systemImage: "sparkles",
            title: "Alle Motivationsquellen",
            subtitle: "Zitate, Wissenschaft und mehr – jeden Tag neu."
        ),
        PremiumBenefit(
            systemImage: "heart.fill",
            title: "Unterstütze deine Reise",
            subtitle: "Bleib motiviert und werbefrei fokussiert."
        )
    ]
}
