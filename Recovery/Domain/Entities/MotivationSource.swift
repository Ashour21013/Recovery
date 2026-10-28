import Foundation

/// Auswählbare Quelle der täglichen Motivation. Reine Domain-Entität.
///
/// Neue Quellen lassen sich durch Ergänzen eines Falls samt zugehörigem
/// `MotivationProvider` hinzufügen (Open/Closed-Prinzip).
enum MotivationSource: String, CaseIterable, Identifiable, Codable, Hashable {
    case quotes
    case science
    case bible
    case mixed

    var id: String { rawValue }

    var title: String {
        switch self {
        case .quotes: String(localized: "Motivationszitate")
        case .science: String(localized: "Wissenschaftlich fundiert")
        case .bible: String(localized: "Bibelverse")
        case .mixed: String(localized: "Gemischte Inhalte")
        }
    }

    var subtitle: String {
        switch self {
        case .quotes: String(localized: "Kurze, kraftvolle Sprüche")
        case .science: String(localized: "Erkenntnisse aus der Forschung")
        case .bible: String(localized: "Verse passend zu deiner Situation")
        case .mixed: String(localized: "Eine Mischung aus allen Quellen")
        }
    }

    var systemImage: String {
        switch self {
        case .quotes: "quote.bubble.fill"
        case .science: "brain.head.profile"
        case .bible: "book.closed.fill"
        case .mixed: "sparkles"
        }
    }

    /// Standardquelle für neue Nutzer.
    static let `default`: MotivationSource = .quotes

    /// Ob diese Quelle zur erweiterten (kostenpflichtigen) Inspiration gehört.
    /// Nur `quotes` ist kostenlos; alle weiteren Quellen sind Premium.
    var isPremium: Bool {
        self != .quotes
    }
}
