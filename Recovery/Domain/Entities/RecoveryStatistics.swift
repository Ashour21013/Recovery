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

    static let empty = RecoveryStatistics(
        currentStreakDays: 0,
        longestStreakDays: 0,
        relapseCount: 0,
        topTriggers: []
    )
}
