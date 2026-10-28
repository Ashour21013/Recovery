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
        case .journal: String(localized: "Journal schreiben")
        case .meditation: String(localized: "2 Minuten Meditation")
        case .motivation: String(localized: "Motivation lesen")
        case .walk: String(localized: "Kurzer Spaziergang")
        case .sport: String(localized: "Sport")
        case .water: String(localized: "Genug Wasser trinken")
        case .gratitude: String(localized: "Dankbarkeit notieren")
        case .breathing: String(localized: "Atemübung")
        case .reading: String(localized: "10 Minuten lesen")
        case .earlySleep: String(localized: "Früh schlafen gehen")
        }
    }

    var subtitle: String {
        switch self {
        case .journal: String(localized: "Halte deine Gedanken und Stimmung fest")
        case .meditation: String(localized: "Komm zur Ruhe und atme bewusst")
        case .motivation: String(localized: "Erinnere dich an dein Warum")
        case .walk: String(localized: "Bewegung an der frischen Luft")
        case .sport: String(localized: "Bring deinen Körper in Schwung")
        case .water: String(localized: "Bleib hydriert für mehr Energie")
        case .gratitude: String(localized: "Drei Dinge, für die du dankbar bist")
        case .breathing: String(localized: "Beruhige dein Nervensystem")
        case .reading: String(localized: "Gönn deinem Kopf eine Pause")
        case .earlySleep: String(localized: "Erholsamer Schlaf stärkt dich")
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
