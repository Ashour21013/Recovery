import Foundation

/// Aktuelle Erfolgssträhne des Nutzers (Anzahl der cleanen Tage).
/// Reine Domain-Entität ohne UI-Bezug.
struct Streak: Equatable {
    /// Aktuelle Anzahl aufeinanderfolgender cleaner Tage.
    let currentDays: Int
    /// Bisher längste erreichte Strähne (für Motivation/Vergleich).
    let bestDays: Int
    /// Startzeitpunkt der aktuellen Strähne.
    let startedAt: Date

    var isNewRecord: Bool { currentDays >= bestDays && currentDays > 0 }
}
