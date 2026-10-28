import Foundation

/// Stimmung eines Journal-Eintrags auf einer Skala von 1–5.
/// Reine Domain-Entität ohne UI-Bezug (Emoji dient nur als semantisches Label).
enum Mood: Int, CaseIterable, Identifiable, Hashable {
    case veryBad = 1
    case bad = 2
    case neutral = 3
    case good = 4
    case veryGood = 5

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .veryBad: String(localized: "Sehr schlecht")
        case .bad: String(localized: "Schlecht")
        case .neutral: String(localized: "Neutral")
        case .good: String(localized: "Gut")
        case .veryGood: String(localized: "Sehr gut")
        }
    }

    var emoji: String {
        switch self {
        case .veryBad: "😞"
        case .bad: "🙁"
        case .neutral: "😐"
        case .good: "🙂"
        case .veryGood: "😄"
        }
    }
}
