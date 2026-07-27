import Foundation

/// Eine einzelne Hilfe-/Beratungs-Ressource.
///
/// Kann entweder eine externe Anlaufstelle (mit Weblink) oder eine
/// In-App-Selbsthilfe-Ressource (ohne Link) sein. Domänen-Entität ohne
/// UI- oder Framework-Abhängigkeiten.
struct HelpResource: Identifiable, Equatable {
    let id: String
    let title: String
    let description: String
    /// Optionaler Weblink zu einem offiziellen Angebot.
    let url: URL?
    /// SF-Symbol zur Illustration.
    let systemImage: String
    let category: HelpResourceCategory

    init(
        id: String,
        title: String,
        description: String,
        url: URL? = nil,
        systemImage: String,
        category: HelpResourceCategory
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.url = url
        self.systemImage = systemImage
        self.category = category
    }
}

/// Kategorisiert eine Hilfe-Ressource.
///
/// `inApp` gruppiert die appeigenen Selbsthilfe-Werkzeuge; `external`
/// gruppiert offizielle Angebote pro Region, sodass weitere Länder leicht
/// ergänzt werden können.
enum HelpResourceCategory: Equatable, Hashable {
    case inApp
    case external(SupportRegion)
}

/// Region/Land eines externen Hilfsangebots.
///
/// Neue Länder werden ausschließlich hier ergänzt – der Rest der App
/// (Provider, View) funktioniert dann automatisch weiter (Open/Closed).
enum SupportRegion: String, CaseIterable, Identifiable, Hashable {
    case germany
    case austria
    case switzerland

    var id: String { rawValue }

    /// Anzeigename inkl. Flaggen-Emoji.
    var title: String {
        switch self {
        case .germany: return "🇩🇪 Deutschland"
        case .austria: return "🇦🇹 Österreich"
        case .switzerland: return "🇨🇭 Schweiz"
        }
    }
}
