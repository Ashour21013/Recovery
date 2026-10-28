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
        case .smoking: String(localized: "Rauchen")
        case .pornography: String(localized: "Pornografie")
        case .alcohol: String(localized: "Alkohol")
        case .gambling: String(localized: "Glücksspiel")
        case .sugar: String(localized: "Zucker")
        case .socialMedia: String(localized: "Social Media")
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
        case .smoking: String(localized: "Frei atmen, länger leben")
        case .pornography: String(localized: "Echte Verbindung statt Bildschirm")
        case .alcohol: String(localized: "Klarer Kopf, mehr Energie")
        case .gambling: String(localized: "Kontrolle zurückgewinnen")
        case .sugar: String(localized: "Mehr Energie, weniger Heißhunger")
        case .socialMedia: String(localized: "Präsenter im echten Leben")
        }
    }
}
