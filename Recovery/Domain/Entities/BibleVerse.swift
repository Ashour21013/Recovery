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
        case .hope: String(localized: "Hoffnung")
        case .temptation: String(localized: "Versuchung")
        case .strength: String(localized: "Stärke")
        case .perseverance: String(localized: "Ausdauer")
        case .forgiveness: String(localized: "Vergebung")
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
