import Foundation

/// Provider für nicht-finanzielle Süchte (Pornografie, Social Media).
///
/// Berechnet die zurückgewonnene Zeit und liefert einen anschaulichen
/// Vergleich (z. B. "entspricht X Arbeitstagen").
struct TimeSavingsProvider: SavingsMetricProvider {

    /// Stunden eines Arbeitstags für den Vergleich.
    private let workdayHours: Double = 8

    func gains(
        for habitType: HabitType,
        streakDays: Int,
        metrics: AddictionMetrics
    ) -> [RecoveryGain] {
        guard streakDays >= 0, let minutesPerDay = metrics.minutesPerDay, minutesPerDay > 0 else {
            return []
        }

        let totalMinutes = minutesPerDay * Double(streakDays)
        let totalHours = totalMinutes / 60.0

        var result: [RecoveryGain] = [
            RecoveryGain(
                id: "time.reclaimed",
                kind: .time,
                value: totalHours,
                unit: totalHours >= 1 ? "Std." : "Min.",
                title: "Zurückgewonnen",
                detail: comparison(totalHours: totalHours),
                systemImage: "clock.arrow.circlepath"
            )
        ]

        // Ergänzend: Zeit in Tagen (24h) für lange Streaks.
        if totalHours >= 24 {
            let days = totalHours / 24.0
            result.append(
                RecoveryGain(
                    id: "time.days",
                    kind: .time,
                    value: days,
                    unit: "Tage",
                    title: "Freie Zeit",
                    detail: "Ganze Tage, die du zurückgewonnen hast",
                    systemImage: "calendar"
                )
            )
        }

        return result
    }

    // MARK: - Vergleich

    private func comparison(totalHours: Double) -> String {
        let workdays = totalHours / workdayHours
        if workdays >= 1 {
            let rounded = Int(workdays.rounded())
            return "Entspricht ca. \(rounded) Arbeitstag\(rounded == 1 ? "" : "en")"
        }
        let movies = totalHours / 2.0
        if movies >= 1 {
            let rounded = Int(movies.rounded())
            return "Entspricht ca. \(rounded) Film\(rounded == 1 ? "" : "en")"
        }
        return "Wertvolle Zeit für dich"
    }
}
