import Foundation

/// Themen-Kategorien für Bibelverse. Reine Domain-Entität.
enum BibleCategory: String, CaseIterable, Codable, Hashable {
    case hope
    case temptation
    case strength
    case perseverance
    case forgiveness

    var title: String {
        switch self {
        case .hope: "Hoffnung"
        case .temptation: "Versuchung"
        case .strength: "Stärke"
        case .perseverance: "Ausdauer"
        case .forgiveness: "Vergebung"
        }
    }
}

/// Ein Bibelvers mit thematischer Zuordnung. Reine Domain-Entität.
struct BibleVerse: Equatable, Identifiable {
    /// Bibelstelle, z. B. "Philipper 4,13" (dient auch als stabile ID).
    let reference: String
    let text: String
    let categories: [BibleCategory]

    var id: String { reference }
}
