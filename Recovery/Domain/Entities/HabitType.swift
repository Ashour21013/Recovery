import Foundation

/// Auswählbare Sucht-/Gewohnheitstypen, die der Nutzer im Onboarding
/// ändern möchte. Reine Domain-Entität ohne UI-Bezug.
enum HabitType: String, CaseIterable, Identifiable, Hashable {
    case smoking
    case pornography
    case alcohol
    case gambling
    case sugar
    case socialMedia

    var id: String { rawValue }

    var title: String {
        switch self {
        case .smoking: "Rauchen"
        case .pornography: "Pornografie"
        case .alcohol: "Alkohol"
        case .gambling: "Glücksspiel"
        case .sugar: "Zucker"
        case .socialMedia: "Social Media"
        }
    }

    var iconName: String {
        switch self {
        case .smoking: "smoke"
        case .pornography: "eye.slash"
        case .alcohol: "wineglass"
        case .gambling: "dice"
        case .sugar: "cube"
        case .socialMedia: "iphone"
        }
    }

    /// Ausdrucksstarkes Emoji für illustrative Darstellung im Onboarding.
    var emoji: String {
        switch self {
        case .smoking: "🚭"
        case .pornography: "🙈"
        case .alcohol: "🍷"
        case .gambling: "🎲"
        case .sugar: "🍬"
        case .socialMedia: "📱"
        }
    }

    /// Kurze, ermutigende Beschreibung der jeweiligen Gewohnheit.
    var subtitle: String {
        switch self {
        case .smoking: "Frei atmen, länger leben"
        case .pornography: "Echte Verbindung statt Bildschirm"
        case .alcohol: "Klarer Kopf, mehr Energie"
        case .gambling: "Kontrolle zurückgewinnen"
        case .sugar: "Mehr Energie, weniger Heißhunger"
        case .socialMedia: "Präsenter im echten Leben"
        }
    }
}
