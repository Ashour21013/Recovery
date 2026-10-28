import Foundation

/// Ein Schritt im Craving-Notfallplan.
///
/// Als `CaseIterable`-Enum modelliert, sodass der Ablauf modular erweitert
/// werden kann: Ein neuer Schritt muss nur hier (in der gewünschten
/// Reihenfolge) und in der View-Zuordnung ergänzt werden.
enum CravingStep: Int, CaseIterable, Identifiable {
    case welcome
    case breathing
    case motivation
    case affirmation
    case reason
    case task
    case finish

    var id: Int { rawValue }

    /// Kurztitel für Fortschrittsanzeige/Navigation.
    var title: String {
        switch self {
        case .welcome: String(localized: "Willkommen")
        case .breathing: String(localized: "Atmen")
        case .motivation: String(localized: "Motivation")
        case .affirmation: String(localized: "Affirmation")
        case .reason: String(localized: "Dein Warum")
        case .task: String(localized: "Kleine Aufgabe")
        case .finish: String(localized: "Geschafft")
        }
    }
}
