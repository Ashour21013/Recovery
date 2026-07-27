import Foundation

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

    init(
        currentStreakDays: Int,
        longestStreakDays: Int,
        addictionTitle: String,
        addictionSystemImage: String,
        startDate: Date,
        isPremium: Bool,
        quotes: [WidgetQuote],
        updatedAt: Date = .now
    ) {
        self.currentStreakDays = currentStreakDays
        self.longestStreakDays = longestStreakDays
        self.addictionTitle = addictionTitle
        self.addictionSystemImage = addictionSystemImage
        self.startDate = startDate
        self.isPremium = isPremium
        self.quotes = quotes
        self.updatedAt = updatedAt
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

    /// Wählt pro Kalendertag deterministisch einen Spruch aus.
    ///
    /// Anhand des Tagesindex (Ordinalzahl des Tages) ändert sich der Spruch
    /// zum Tageswechsel, bleibt aber innerhalb eines Tages konstant.
    func quote(for date: Date = .now, calendar: Calendar = .current) -> WidgetQuote? {
        guard !quotes.isEmpty else { return nil }
        let dayIndex = calendar.ordinality(of: .day, in: .era, for: date) ?? 0
        return quotes[dayIndex % quotes.count]
    }
}
