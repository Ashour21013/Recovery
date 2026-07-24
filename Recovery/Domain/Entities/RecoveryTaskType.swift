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
    case water
    case gratitude
    case breathing
    case reading
    case earlySleep

    var id: String { rawValue }

    var title: String {
        switch self {
        case .journal: "Journal schreiben"
        case .meditation: "2 Minuten Meditation"
        case .motivation: "Motivation lesen"
        case .walk: "Kurzer Spaziergang"
        case .sport: "Sport"
        case .water: "Genug Wasser trinken"
        case .gratitude: "Dankbarkeit notieren"
        case .breathing: "Atemübung"
        case .reading: "10 Minuten lesen"
        case .earlySleep: "Früh schlafen gehen"
        }
    }

    var subtitle: String {
        switch self {
        case .journal: "Halte deine Gedanken und Stimmung fest"
        case .meditation: "Komm zur Ruhe und atme bewusst"
        case .motivation: "Erinnere dich an dein Warum"
        case .walk: "Bewegung an der frischen Luft"
        case .sport: "Bring deinen Körper in Schwung"
        case .water: "Bleib hydriert für mehr Energie"
        case .gratitude: "Drei Dinge, für die du dankbar bist"
        case .breathing: "Beruhige dein Nervensystem"
        case .reading: "Gönn deinem Kopf eine Pause"
        case .earlySleep: "Erholsamer Schlaf stärkt dich"
        }
    }

    var systemImage: String {
        switch self {
        case .journal: "book.fill"
        case .meditation: "leaf.fill"
        case .motivation: "quote.bubble.fill"
        case .walk: "figure.walk"
        case .sport: "figure.run"
        case .water: "drop.fill"
        case .gratitude: "heart.text.square.fill"
        case .breathing: "wind"
        case .reading: "books.vertical.fill"
        case .earlySleep: "moon.zzz.fill"
        }
    }

    /// Standard-Plan, der beim Onboarding automatisch erstellt wird.
    static let defaultPlan: [RecoveryTaskType] = [
        .journal, .meditation, .motivation, .walk, .sport
    ]

    /// Zusätzliche Vorschläge, die der Nutzer optional übernehmen kann.
    static let suggestions: [RecoveryTaskType] = [
        .water, .gratitude, .breathing, .reading, .earlySleep
    ]
}
