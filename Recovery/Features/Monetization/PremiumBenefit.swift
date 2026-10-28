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
            title: String(localized: "Unbegrenzter Zugang"),
            subtitle: String(localized: "Alle Funktionen ohne Einschränkungen nutzen.")
        ),
        PremiumBenefit(
            systemImage: "chart.line.uptrend.xyaxis",
            title: String(localized: "Erweiterte Statistiken"),
            subtitle: String(localized: "Tiefergehende Einblicke in deinen Fortschritt.")
        ),
        PremiumBenefit(
            systemImage: "sparkles",
            title: String(localized: "Alle Motivationsquellen"),
            subtitle: String(localized: "Zitate, Wissenschaft und mehr – jeden Tag neu.")
        ),
        PremiumBenefit(
            systemImage: "heart.fill",
            title: String(localized: "Unterstütze deine Reise"),
            subtitle: String(localized: "Bleib motiviert und werbefrei fokussiert.")
        )
    ]
}
