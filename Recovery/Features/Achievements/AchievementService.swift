import Foundation

/// Momentaufnahme der für Achievements relevanten Kennzahlen.
/// Entkoppelt die Auswertungslogik von der Datenquelle.
struct AchievementContext {
    let currentStreakDays: Int
    let hoursSinceStart: Int
    let journalCount: Int
    let completedCravingSessions: Int
    let relapseCount: Int
    /// Ob seit mindestens 7 Tagen kein Rückfall passiert ist.
    let daysSinceLastRelapse: Int?
}

/// Abstraktion für das Freischalten und Laden von Achievements.
///
/// ViewModels kennen nur dieses Protokoll, niemals SwiftData. Die Bewertung,
/// welche Achievements erfüllt sind, liegt hinter dieser Schnittstelle.
protocol AchievementService {

    /// Lädt alle Achievements (freigeschaltet + gesperrt) zur Anzeige.
    func allAchievements() async -> [Achievement]

    /// Wertet den aktuellen Kontext aus und schaltet neu erfüllte
    /// Achievements frei. Gibt die dabei **neu** freigeschalteten zurück.
    @discardableResult
    func evaluate(_ context: AchievementContext) async -> [Achievement]
}
