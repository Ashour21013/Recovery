import Foundation

/// Auswählbare Quelle der Motivationssprüche im Widget.
///
/// Spiegelt die App-Quellen (Zitate, Wissenschaft, Bibel, Gemischt). Bewusst
/// als eigener, `Codable` String-Enum ohne App-Abhängigkeiten, damit er in
/// beiden Targets nutzbar ist.
enum WidgetQuoteSource: String, Codable, CaseIterable {
    case quotes
    case science
    case bible
    case mixed

    var title: String {
        switch self {
        case .quotes: "Motivationszitate"
        case .science: "Wissenschaft"
        case .bible: "Bibelverse"
        case .mixed: "Gemischt"
        }
    }

    /// Ob diese Quelle Premium erfordert (nur `quotes` ist kostenlos).
    var isPremium: Bool { self != .quotes }
}

/// Ein reduzierter, für das Widget bestimmter Motivationsspruch.
///
/// Bewusst schlank und `Codable`, damit er ohne App-interne Abhängigkeiten
/// (SwiftData, Provider) über die App Group geteilt werden kann.
struct WidgetQuote: Codable, Equatable, Identifiable {
    let id: String
    let text: String
    /// Autor bzw. Quelle (z. B. Bibelstelle), optional.
    let author: String?

    init(id: String, text: String, author: String?) {
        self.id = id
        self.text = text
        self.author = author
    }
}

/// Die pro getrackter Sucht benötigten Anzeigedaten fürs Widget.
///
/// Bewusst schlank und `Codable`, damit jede Sucht ohne App-interne
/// Abhängigkeiten (SwiftData) über die App Group geteilt werden kann.
struct WidgetAddiction: Codable, Equatable, Identifiable {
    /// Stabile Kennung (entspricht der Profil-ID in der App).
    let id: String
    /// Anzeigename der Sucht (z. B. "Rauchen").
    let title: String
    /// SF-Symbol-Name für das Icon der Sucht.
    let systemImage: String
    /// Aktuelle Streak in Tagen.
    let currentStreakDays: Int
    /// Längste bisher erreichte Streak in Tagen.
    let longestStreakDays: Int
    /// Startdatum der aktuellen Strähne.
    let startDate: Date
    /// Ob diese Sucht aktuell die aktive (im Dashboard angezeigte) ist.
    let isActive: Bool

    init(
        id: String,
        title: String,
        systemImage: String,
        currentStreakDays: Int,
        longestStreakDays: Int,
        startDate: Date,
        isActive: Bool
    ) {
        self.id = id
        self.title = title
        self.systemImage = systemImage
        self.currentStreakDays = currentStreakDays
        self.longestStreakDays = longestStreakDays
        self.startDate = startDate
        self.isActive = isActive
    }
}

/// Momentaufnahme aller Daten, die das Widget zur Anzeige benötigt.
///
/// Wird von der Haupt-App in die App Group geschrieben und vom Widget nur
/// gelesen. Enthält keine Business-Logik – reine Transportstruktur (`Codable`).
struct WidgetSnapshot: Codable, Equatable {
    /// Aktuelle Streak in Tagen.
    let currentStreakDays: Int
    /// Längste bisher erreichte Streak in Tagen.
    let longestStreakDays: Int
    /// Anzeigename der aktiven Sucht (z. B. "Rauchen").
    let addictionTitle: String
    /// SF-Symbol-Name für das Icon der aktiven Sucht.
    let addictionSystemImage: String
    /// Startdatum der aktuellen Strähne.
    let startDate: Date
    /// Ob der Nutzer Premium besitzt (steuert das Widget-Gating).
    let isPremium: Bool
    /// Geteilte (ggf. reduzierte) Liste der Motivationssprüche.
    let quotes: [WidgetQuote]
    /// Zeitpunkt der letzten Aktualisierung durch die App.
    let updatedAt: Date

    /// Daten ALLER getrackten Süchte (für konfigurierbare Widgets).
    /// Optional dekodiert, um Abwärtskompatibilität mit älteren Snapshots
    /// ohne dieses Feld zu wahren.
    let addictions: [WidgetAddiction]

    /// Sprüche je Quelle (für die Quellen-Auswahl im Widget). Nur die dem
    /// Nutzer erlaubten Quellen sind befüllt (Free: nur `quotes`).
    let quotesBySource: [String: [WidgetQuote]]

    init(
        currentStreakDays: Int,
        longestStreakDays: Int,
        addictionTitle: String,
        addictionSystemImage: String,
        startDate: Date,
        isPremium: Bool,
        quotes: [WidgetQuote],
        addictions: [WidgetAddiction] = [],
        quotesBySource: [String: [WidgetQuote]] = [:],
        updatedAt: Date = .now
    ) {
        self.currentStreakDays = currentStreakDays
        self.longestStreakDays = longestStreakDays
        self.addictionTitle = addictionTitle
        self.addictionSystemImage = addictionSystemImage
        self.startDate = startDate
        self.isPremium = isPremium
        self.quotes = quotes
        self.addictions = addictions
        self.quotesBySource = quotesBySource
        self.updatedAt = updatedAt
    }

    private enum CodingKeys: String, CodingKey {
        case currentStreakDays, longestStreakDays, addictionTitle
        case addictionSystemImage, startDate, isPremium, quotes, addictions
        case quotesBySource, updatedAt
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        currentStreakDays = try c.decode(Int.self, forKey: .currentStreakDays)
        longestStreakDays = try c.decode(Int.self, forKey: .longestStreakDays)
        addictionTitle = try c.decode(String.self, forKey: .addictionTitle)
        addictionSystemImage = try c.decode(String.self, forKey: .addictionSystemImage)
        startDate = try c.decode(Date.self, forKey: .startDate)
        isPremium = try c.decode(Bool.self, forKey: .isPremium)
        quotes = try c.decode([WidgetQuote].self, forKey: .quotes)
        addictions = try c.decodeIfPresent([WidgetAddiction].self, forKey: .addictions) ?? []
        quotesBySource = try c.decodeIfPresent([String: [WidgetQuote]].self, forKey: .quotesBySource) ?? [:]
        updatedAt = try c.decode(Date.self, forKey: .updatedAt)
    }

    /// Platzhalter-Snapshot für Previews und den Zustand ohne geteilte Daten.
    static let placeholder = WidgetSnapshot(
        currentStreakDays: 12,
        longestStreakDays: 30,
        addictionTitle: "Rauchen",
        addictionSystemImage: "smoke",
        startDate: Calendar.current.date(byAdding: .day, value: -12, to: .now) ?? .now,
        isPremium: true,
        quotes: [
            WidgetQuote(id: "ph.1", text: "Du bist stärker als deine Gewohnheit.", author: nil),
            WidgetQuote(id: "ph.2", text: "Jeder Tag ohne Rückfall ist ein Sieg über dich selbst.", author: nil)
        ]
    )
    /// Kopie mit geändertem Premium-Status (für schnelle Entitlement-Updates,
    /// ohne den Snapshot vollständig aus dem Profil neu aufzubauen).
    func withPremium(_ isPremium: Bool) -> WidgetSnapshot {
        WidgetSnapshot(
            currentStreakDays: currentStreakDays,
            longestStreakDays: longestStreakDays,
            addictionTitle: addictionTitle,
            addictionSystemImage: addictionSystemImage,
            startDate: startDate,
            isPremium: isPremium,
            quotes: quotes,
            addictions: addictions,
            quotesBySource: quotesBySource,
            updatedAt: .now
        )
    }

    /// Wählt pro Kalendertag deterministisch einen Spruch aus.
    ///
    /// Anhand des Tagesindex (Ordinalzahl des Tages) ändert sich der Spruch
    /// zum Tageswechsel, bleibt aber innerhalb eines Tages konstant.
    func quote(for date: Date = .now, calendar: Calendar = .current) -> WidgetQuote? {
        guard !quotes.isEmpty else { return nil }
        let dayIndex = calendar.ordinality(of: .day, in: .era, for: date) ?? 0
        return quotes[dayIndex % quotes.count]
    }

    /// Wählt pro Kalendertag deterministisch einen Spruch aus der gewählten Quelle.
    ///
    /// Greift auf `quotesBySource[source]` zurück; ist die Quelle leer oder für
    /// Free-Nutzer gesperrt, wird auf die Standard-`quotes` zurückgefallen.
    func quote(for date: Date = .now,
               source: WidgetQuoteSource,
               calendar: Calendar = .current) -> WidgetQuote? {
        let pool = quotesBySource[source.rawValue] ?? []
        let usable = (!pool.isEmpty && (isPremium || !source.isPremium)) ? pool : quotes
        guard !usable.isEmpty else { return nil }
        let dayIndex = calendar.ordinality(of: .day, in: .era, for: date) ?? 0
        return usable[dayIndex % usable.count]
    }

    /// Löst die anzuzeigende Sucht für ein konfigurierbares Widget auf.
    ///
    /// - Bei gültiger, noch existierender Auswahl: diese Sucht.
    /// - Sonst (keine Auswahl, Sentinel `"active"`, oder gelöschte Sucht):
    ///   die aktive Sucht, ersatzweise die Top-Level-Felder des Snapshots.
    ///
    /// Der ID-Abgleich erfolgt NORMALISIERT (getrimmt + `lowercased`), damit
    /// er nicht an Groß-/Kleinschreibung oder Whitespace-Unterschieden
    /// zwischen Schreib- (App) und Lesepfad (Widget-Intent) scheitert.
    func resolvedAddiction(preferredID: String?) -> WidgetAddiction {
        let normalized = preferredID?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        // Nur echte Auswahl matchen – der Sentinel "active" bedeutet
        // ausdrücklich "keine konkrete Auswahl → aktive Sucht".
        if let key = normalized, !key.isEmpty, key != "active",
           let match = addictions.first(where: {
               $0.id.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == key
           }) {
            return match
        }

        if let active = addictions.first(where: { $0.isActive }) ?? addictions.first {
            return active
        }
        // Fallback auf die (Top-Level-)Aktiv-Daten, wenn keine Liste vorliegt.
        return WidgetAddiction(
            id: "active",
            title: addictionTitle,
            systemImage: addictionSystemImage,
            currentStreakDays: currentStreakDays,
            longestStreakDays: longestStreakDays,
            startDate: startDate,
            isActive: true
        )
    }
}
