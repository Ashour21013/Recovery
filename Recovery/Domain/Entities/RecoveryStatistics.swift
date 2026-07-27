import Foundation

/// Häufigkeit eines einzelnen Triggers (für Auswertung/Charts).
/// Reine Domain-Entität ohne UI-Bezug.
struct TriggerFrequency: Equatable, Identifiable {
    var id: String { name }
    let name: String
    let count: Int
}

/// Aggregierte Statistik-Kennzahlen der Recovery-Reise.
/// Reine Domain-Entität – die Aufbereitung übernimmt das ViewModel.
struct RecoveryStatistics: Equatable {
    let currentStreakDays: Int
    let longestStreakDays: Int
    let relapseCount: Int
    /// Häufigste Trigger, absteigend sortiert.
    let topTriggers: [TriggerFrequency]
    /// Streak-Verlauf der letzten 30 Tage (für das Liniendiagramm).
    let streakHistory: [StreakPoint]
    /// Rückfälle je Woche (für das Balkendiagramm).
    let relapseBuckets: [RelapseBucket]

    init(
        currentStreakDays: Int,
        longestStreakDays: Int,
        relapseCount: Int,
        topTriggers: [TriggerFrequency],
        streakHistory: [StreakPoint] = [],
        relapseBuckets: [RelapseBucket] = []
    ) {
        self.currentStreakDays = currentStreakDays
        self.longestStreakDays = longestStreakDays
        self.relapseCount = relapseCount
        self.topTriggers = topTriggers
        self.streakHistory = streakHistory
        self.relapseBuckets = relapseBuckets
    }

    static let empty = RecoveryStatistics(
        currentStreakDays: 0,
        longestStreakDays: 0,
        relapseCount: 0,
        topTriggers: []
    )

    /// Ob überhaupt nennenswerte Nutzerdaten vorliegen (für Empty States).
    var hasData: Bool {
        currentStreakDays > 0 || longestStreakDays > 0
            || relapseCount > 0 || !topTriggers.isEmpty
    }
}
