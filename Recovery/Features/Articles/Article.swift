import SwiftUI

/// Art des Artikels – bestimmt Icon, Label und Layout-Variante.
enum ArticleCategory: String, CaseIterable, Identifiable {
    case impact, facts, methods, recovery, stories, triggers

    var id: String { rawValue }

    var title: String {
        switch self {
        case .impact: String(localized: "Auswirkungen")
        case .facts: String(localized: "Zahlen & Fakten")
        case .methods: String(localized: "Methoden")
        case .recovery: String(localized: "Erholung")
        case .stories: String(localized: "Erfahrungen")
        case .triggers: String(localized: "Verlangen & Rückfall")
        }
    }

    var icon: String {
        switch self {
        case .impact: "heart.text.square"
        case .facts: "chart.bar.xaxis"
        case .methods: "checklist"
        case .recovery: "leaf"
        case .stories: "quote.bubble"
        case .triggers: "waveform.path.ecg"
        }
    }

    var index: Int { Self.allCases.firstIndex(of: self) ?? 0 }
}

enum ArticleBlock {
    case paragraph(String)
    case heading(String)
    case stat(value: String, label: String)
    case quote(text: String, attribution: String?)
    case list([String])
    case steps([Step])
    case callout(title: String, text: String)

    struct Step: Decodable, Hashable {
        let title: String
        let text: String
    }
}

extension ArticleBlock: Decodable {
    private enum Key: String, CodingKey { case type, text, value, label, attribution, items, title }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: Key.self)
        let type = try c.decode(String.self, forKey: .type)
        switch type {
        case "heading": self = .heading(try c.decode(String.self, forKey: .text))
        case "stat": self = .stat(value: try c.decode(String.self, forKey: .value), label: try c.decode(String.self, forKey: .label))
        case "quote": self = .quote(text: try c.decode(String.self, forKey: .text), attribution: try c.decodeIfPresent(String.self, forKey: .attribution))
        case "list": self = .list(try c.decode([String].self, forKey: .items))
        case "steps": self = .steps(try c.decode([Step].self, forKey: .items))
        case "callout": self = .callout(title: try c.decode(String.self, forKey: .title), text: try c.decode(String.self, forKey: .text))
        default: self = .paragraph(try c.decode(String.self, forKey: .text))
        }
    }
}

struct ArticleSource: Decodable, Hashable {
    let name: String
    let url: String?
}

struct Article: Identifiable {
    let id: String
    let habit: HabitType
    let category: ArticleCategory
    let readMinutes: Int
    let title: String
    let subtitle: String
    let blocks: [ArticleBlock]
    let sources: [ArticleSource]
}

// MARK: - Laden (Deutsch, sonst Englisch)

private struct RawArticle: Decodable {
    struct Text: Decodable {
        let title: String
        let subtitle: String
        let blocks: [ArticleBlock]
    }
    let id: String
    let habit: String
    let category: String
    let readMinutes: Int
    let de: Text
    let en: Text
    let sources: [ArticleSource]?
}

private struct RawFile: Decodable { let articles: [RawArticle] }

enum ArticleLibrary {

    /// Alle Artikel in der Gerätesprache, sortiert nach Sucht und Kategorie.
    static func load(preferGerman: Bool = Locale.current.language.languageCode?.identifier == "de") -> [Article] {
        let urls = (Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) ?? [])
            .filter { $0.lastPathComponent.hasPrefix("articles-") }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }

        var result: [Article] = []
        for url in urls {
            guard let data = try? Data(contentsOf: url),
                  let file = try? JSONDecoder().decode(RawFile.self, from: data) else { continue }
            for raw in file.articles {
                guard let habit = HabitType(rawValue: raw.habit),
                      let category = ArticleCategory(rawValue: raw.category) else { continue }
                let text = preferGerman ? raw.de : raw.en
                result.append(Article(
                    id: raw.id, habit: habit, category: category, readMinutes: raw.readMinutes,
                    title: text.title, subtitle: text.subtitle, blocks: text.blocks, sources: raw.sources ?? []
                ))
            }
        }
        return result.sorted {
            let a = HabitType.allCases.firstIndex(of: $0.habit) ?? 0
            let b = HabitType.allCases.firstIndex(of: $1.habit) ?? 0
            return a != b ? a < b : $0.category.index < $1.category.index
        }
    }
}

// MARK: - Gestaltung pro Artikel

/// Eindeutige, deterministische Farbwelt und Cover-Motiv pro Artikel.
struct ArticleTheme {
    let style: Int
    let seed: UInt64
    let light: Color
    let mid: Color
    let dark: Color

    static let styleCount = 10

    init(article: Article) {
        let habitIndex = HabitType.allCases.firstIndex(of: article.habit) ?? 0
        let baseHue: [Double] = [0.08, 0.80, 0.97, 0.38, 0.13, 0.58]
        var hue = baseHue[habitIndex % baseHue.count] + Double(article.category.index) * 0.035
        hue = hue.truncatingRemainder(dividingBy: 1)
        style = (habitIndex * 4 + article.category.index * 3 + habitIndex / 2) % Self.styleCount
        seed = Self.fnv(article.id)
        light = Color(hue: hue, saturation: 0.30, brightness: 0.98)
        mid = Color(hue: hue, saturation: 0.62, brightness: 0.86)
        dark = Color(hue: (hue + 0.04).truncatingRemainder(dividingBy: 1), saturation: 0.75, brightness: 0.38)
    }

    private static func fnv(_ s: String) -> UInt64 {
        var h: UInt64 = 1469598103934665603
        for b in s.utf8 { h = (h ^ UInt64(b)) &* 1099511628211 }
        return h
    }
}

struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed == 0 ? 0x9E3779B97F4A7C15 : seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}
