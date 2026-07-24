import Foundation

/// Alle möglichen Achievements (Badges). Reine Domain-Entität ohne UI-Bezug.
///
/// Jeder Case trägt seine Metadaten (Titel, Beschreibung, Symbol, Farbe),
/// sodass neue Achievements zentral und wiederverwendbar ergänzt werden können.
enum AchievementType: String, CaseIterable, Identifiable, Codable {
    case first24Hours
    case threeDays
    case sevenDays
    case thirtyDays
    case ninetyDays
    case oneYear
    case firstJournal
    case tenJournals
    case firstCraving
    case firstWeekNoRelapse

    var id: String { rawValue }

    var title: String {
        switch self {
        case .first24Hours: "Erste 24 Stunden"
        case .threeDays: "3 Tage"
        case .sevenDays: "7 Tage"
        case .thirtyDays: "30 Tage"
        case .ninetyDays: "90 Tage"
        case .oneYear: "365 Tage"
        case .firstJournal: "Erstes Journal"
        case .tenJournals: "10 Journale"
        case .firstCraving: "Craving gemeistert"
        case .firstWeekNoRelapse: "Woche ohne Rückfall"
        }
    }

    var details: String {
        switch self {
        case .first24Hours: "Die ersten 24 Stunden geschafft."
        case .threeDays: "Drei Tage am Stück clean."
        case .sevenDays: "Eine ganze Woche durchgehalten."
        case .thirtyDays: "30 Tage – ein starker Monat."
        case .ninetyDays: "90 Tage voller Disziplin."
        case .oneYear: "Ein ganzes Jahr. Unglaublich!"
        case .firstJournal: "Deinen ersten Journal-Eintrag geschrieben."
        case .tenJournals: "Zehn Journal-Einträge festgehalten."
        case .firstCraving: "Ein Verlangen erfolgreich überstanden."
        case .firstWeekNoRelapse: "Eine Woche ohne einen Rückfall."
        }
    }

    var systemImage: String {
        switch self {
        case .first24Hours: "sunrise.fill"
        case .threeDays: "leaf.fill"
        case .sevenDays: "calendar"
        case .thirtyDays: "flame.fill"
        case .ninetyDays: "star.fill"
        case .oneYear: "crown.fill"
        case .firstJournal: "book.fill"
        case .tenJournals: "books.vertical.fill"
        case .firstCraving: "bolt.heart.fill"
        case .firstWeekNoRelapse: "shield.lefthalf.filled"
        }
    }

    /// Farbe des Badges als semantischer Name (in der UI aufgelöst).
    var colorName: AchievementColor {
        switch self {
        case .first24Hours: .orange
        case .threeDays: .green
        case .sevenDays: .blue
        case .thirtyDays: .red
        case .ninetyDays: .yellow
        case .oneYear: .purple
        case .firstJournal: .teal
        case .tenJournals: .indigo
        case .firstCraving: .pink
        case .firstWeekNoRelapse: .mint
        }
    }
}

/// UI-unabhängige Farbcodierung für Badges.
enum AchievementColor: String, Codable {
    case orange, green, blue, red, yellow, purple, teal, indigo, pink, mint
}
