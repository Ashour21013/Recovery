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
}
