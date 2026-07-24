import Foundation

/// Situativer Kontext, anhand dessen möglichst passende Motivation gewählt
/// wird (z. B. passende Bibelverse). Reine Domain-Entität.
enum MotivationContext: String, Equatable, Codable {
    /// Normaler Tag ohne besonderes Ereignis.
    case daily
    /// Akutes Verlangen ("Cravings").
    case craving
    /// Kürzlich erfolgter Rückfall.
    case relapse
    /// Ein Meilenstein wurde erreicht.
    case milestone

    /// Passende Bibel-Kategorien für diesen Kontext (Priorität absteigend).
    var preferredBibleCategories: [BibleCategory] {
        switch self {
        case .daily: [.hope, .strength, .perseverance]
        case .craving: [.temptation, .strength]
        case .relapse: [.forgiveness, .hope]
        case .milestone: [.perseverance, .strength, .hope]
        }
    }
}

/// Ein einzelnes Motivations-Element zur Anzeige. Reine Domain-Entität.
struct MotivationItem: Equatable, Identifiable {
    /// Stabile Kennung zur Wiederholungsvermeidung (z. B. Zitat-Text-Hash).
    let id: String
    let text: String
    /// Autor bzw. Quelle (z. B. Bibelstelle "Philipper 4,13").
    let source: String?
    /// Herkunft des Inhalts (für Icon/Beschriftung).
    let origin: MotivationSource

    init(id: String, text: String, source: String?, origin: MotivationSource) {
        self.id = id
        self.text = text
        self.source = source
        self.origin = origin
    }
}
