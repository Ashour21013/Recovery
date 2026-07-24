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
    case reason
    case task
    case finish

    var id: Int { rawValue }

    /// Kurztitel für Fortschrittsanzeige/Navigation.
    var title: String {
        switch self {
        case .welcome: "Willkommen"
        case .breathing: "Atmen"
        case .motivation: "Motivation"
        case .reason: "Dein Warum"
        case .task: "Kleine Aufgabe"
        case .finish: "Geschafft"
        }
    }
}
