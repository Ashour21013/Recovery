import Foundation

/// Ein Punkt im Streak-Verlauf (clean days an einem bestimmten Tag).
/// Reine Domain-Entität für das Streak-Liniendiagramm.
struct StreakPoint: Equatable, Identifiable {
    var id: Date { date }
    let date: Date
    let streakDays: Int
}

/// Anzahl der Rückfälle in einem Zeitfenster (z. B. eine Woche).
/// Reine Domain-Entität für das Rückfall-Balkendiagramm.
struct RelapseBucket: Equatable, Identifiable {
    var id: Date { periodStart }
    /// Beginn des Zeitfensters (z. B. Wochenanfang).
    let periodStart: Date
    let count: Int
}
