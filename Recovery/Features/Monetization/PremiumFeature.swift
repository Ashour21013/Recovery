import Foundation

/// Alle kostenpflichtigen Features der App (Feature-Gating).
///
/// Zentrale, typsichere Liste aller Premium-Funktionen. Der
/// `FeatureAccessService` entscheidet anhand dieses Enums, ob ein Feature
/// freigeschaltet ist. Reine Domain-Entität ohne UI-Bezug.
enum PremiumFeature: String, CaseIterable, Identifiable {
    /// Mehrere Süchte gleichzeitig tracken.
    case multipleSuchte
    /// Alle Statistiken & Charts.
    case alleStatistiken
    /// Recovery-Gain-System (gespartes Geld / zurückgewonnene Zeit).
    case recoveryGains
    /// Alle App Icons.
    case alleAppIcons
    /// Erweiterte Inspiration (z. B. Bibelverse).
    case erweiterteInspiration
    /// iCloud-Synchronisation.
    case iCloudSync
    /// Home-Screen-Widgets.
    case widgets

    var id: String { rawValue }

    /// Sprechender Titel für Paywall/Badges.
    var title: String {
        switch self {
        case .multipleSuchte: "Mehrere Süchte"
        case .alleStatistiken: "Alle Statistiken"
        case .recoveryGains: "Fortschritts-Gewinne"
        case .alleAppIcons: "Alle App-Icons"
        case .erweiterteInspiration: "Erweiterte Inspiration"
        case .iCloudSync: "iCloud-Sync"
        case .widgets: "Widgets"
        }
    }

    /// Einladender Teaser-Titel für die `LockedFeatureCard`.
    var teaserTitle: String {
        switch self {
        case .multipleSuchte: "Mehrere Gewohnheiten"
        case .alleStatistiken: "Statistiken"
        case .recoveryGains: "Deine Erfolge"
        case .alleAppIcons: "Alle App-Icons"
        case .erweiterteInspiration: "Mehr Motivation"
        case .iCloudSync: "iCloud-Sync"
        case .widgets: "Widgets"
        }
    }

    /// Kurze, motivierende Nutzen-Beschreibung für die `LockedFeatureCard`.
    var teaserDescription: String {
        switch self {
        case .multipleSuchte:
            "Tracke mehrere Gewohnheiten gleichzeitig an einem Ort."
        case .alleStatistiken:
            "Sieh deine längste Streak, Rückfälle und häufigsten Trigger als übersichtliche Diagramme."
        case .recoveryGains:
            "Sieh, wie viel Geld oder Zeit du seit deinem Start zurückgewonnen hast."
        case .alleAppIcons:
            "Wähle aus verschiedenen App-Icons dein Lieblingsdesign."
        case .erweiterteInspiration:
            "Schalte zusätzliche Motivationsquellen frei, z. B. Bibelverse."
        case .iCloudSync:
            "Synchronisiere deinen Fortschritt sicher über all deine Geräte."
        case .widgets:
            "Behalte deine Streak direkt vom Home-Bildschirm im Blick."
        }
    }

    /// SF-Symbol zur illustrativen Darstellung des Features.
    var systemImage: String {
        switch self {
        case .multipleSuchte: "square.stack.3d.up.fill"
        case .alleStatistiken: "chart.bar.xaxis"
        case .recoveryGains: "sparkles"
        case .alleAppIcons: "app.badge.fill"
        case .erweiterteInspiration: "quote.bubble.fill"
        case .iCloudSync: "icloud.fill"
        case .widgets: "square.grid.2x2.fill"
        }
    }
}
