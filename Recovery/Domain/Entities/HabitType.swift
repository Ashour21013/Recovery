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
}
