import Foundation

/// Katalog möglicher täglicher Aufgaben eines Recovery-Plans.
///
/// Reine Domain-Entität ohne UI-Bezug. Neue Aufgaben lassen sich zentral
/// durch Ergänzen eines Falls hinzufügen (modular & erweiterbar).
enum RecoveryTaskType: String, CaseIterable, Identifiable, Codable, Hashable {
    case journal
    case meditation
    case motivation
    case walk
    case sport

    var id: String { rawValue }

    var title: String {
        switch self {
        case .journal: "Journal schreiben"
        case .meditation: "2 Minuten Meditation"
        case .motivation: "Motivation lesen"
        case .walk: "Kurzer Spaziergang"
        case .sport: "Sport"
        }
    }

    var subtitle: String {
        switch self {
        case .journal: "Halte deine Gedanken und Stimmung fest"
        case .meditation: "Komm zur Ruhe und atme bewusst"
        case .motivation: "Erinnere dich an dein Warum"
        case .walk: "Bewegung an der frischen Luft"
        case .sport: "Bring deinen Körper in Schwung"
        }
    }

    var systemImage: String {
        switch self {
        case .journal: "book.fill"
        case .meditation: "leaf.fill"
        case .motivation: "quote.bubble.fill"
        case .walk: "figure.walk"
        case .sport: "figure.run"
        }
    }

    /// Standard-Plan, der beim Onboarding automatisch erstellt wird.
    static let defaultPlan: [RecoveryTaskType] = [
        .journal, .meditation, .motivation, .walk, .sport
    ]
}
