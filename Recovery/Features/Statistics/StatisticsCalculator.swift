import Foundation

/// Berechnet aus den Rohdaten (Profil, Rückfälle, Journal) die aggregierten
/// Statistik-Kennzahlen. Reine, zustandslose Domain-Logik – dadurch leicht
/// testbar und frei von UI/Persistenz.
enum StatisticsCalculator {

    /// Ermittelt die häufigsten Trigger aus Journal-Einträgen und separat
    /// erfassten Triggern.
    static func topTriggers(
        journalEntries: [JournalEntry],
        triggers: [Trigger],
        limit: Int = 5
    ) -> [TriggerFrequency] {
        var counts: [String: Int] = [:]

        for entry in journalEntries {
            guard let raw = entry.triggerName else { continue }
            let name = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !name.isEmpty else { continue }
            counts[name, default: 0] += 1
        }

        for trigger in triggers {
            let name = trigger.name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !name.isEmpty else { continue }
            counts[name, default: 0] += 1
        }

        let frequencies: [TriggerFrequency] = counts.map { key, value in
            TriggerFrequency(name: key, count: value)
        }

        let sorted = frequencies.sorted { lhs, rhs in
            if lhs.count == rhs.count {
                return lhs.name < rhs.name
            }
            return lhs.count > rhs.count
        }

        return Array(sorted.prefix(limit))
    }

    /// Erstellt das vollständige Statistik-Aggregat.
    static func makeStatistics(
        profile: RecoveryProfile,
        relapses: [Relapse],
        journalEntries: [JournalEntry],
        triggers: [Trigger],
        now: Date = .now
    ) -> RecoveryStatistics {
        let streak = profile.streak(now: now)
        return RecoveryStatistics(
            currentStreakDays: streak.currentDays,
            longestStreakDays: streak.bestDays,
            relapseCount: relapses.count,
            topTriggers: topTriggers(journalEntries: journalEntries, triggers: triggers)
        )
    }
}
