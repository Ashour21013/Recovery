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
            topTriggers: topTriggers(journalEntries: journalEntries, triggers: triggers),
            streakHistory: streakHistory(profile: profile, relapses: relapses, now: now),
            relapseBuckets: relapseBuckets(relapses: relapses, now: now)
        )
    }

    /// Berechnet den Streak-Verlauf (clean days) der letzten `days` Tage.
    ///
    /// Für jeden Tag wird die Anzahl cleaner Tage seit dem letzten Rückfall
    /// (bzw. seit Streak-Beginn) ermittelt. Rückfälle setzen die Kurve auf 0.
    static func streakHistory(
        profile: RecoveryProfile,
        relapses: [Relapse],
        now: Date = .now,
        days: Int = 30,
        calendar: Calendar = .current
    ) -> [StreakPoint] {
        let today = calendar.startOfDay(for: now)
        // Sortierte Rückfall-Tage für die Suche nach dem letzten Rückfall.
        let relapseDays = relapses
            .map { calendar.startOfDay(for: $0.date) }
            .sorted()
        let streakStart = calendar.startOfDay(for: profile.startDate)

        return (0..<days).reversed().compactMap { offset -> StreakPoint? in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else {
                return nil
            }
            // Letzter Rückfall an oder vor diesem Tag.
            let lastRelapse = relapseDays.last { $0 <= day }
            // Referenzpunkt: max(letzter Rückfall, Streak-Beginn).
            let reference = [lastRelapse, streakStart].compactMap { $0 }.max() ?? streakStart
            let value = calendar.dateComponents([.day], from: reference, to: day).day ?? 0
            return StreakPoint(date: day, streakDays: max(0, value))
        }
    }

    /// Gruppiert Rückfälle in Wochen-Buckets über die letzten `weeks` Wochen.
    static func relapseBuckets(
        relapses: [Relapse],
        now: Date = .now,
        weeks: Int = 8,
        calendar: Calendar = .current
    ) -> [RelapseBucket] {
        let today = calendar.startOfDay(for: now)
        guard let currentWeekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start else {
            return []
        }

        return (0..<weeks).reversed().compactMap { offset -> RelapseBucket? in
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -offset, to: currentWeekStart),
                  let weekEnd = calendar.date(byAdding: .weekOfYear, value: 1, to: weekStart)
            else { return nil }
            let count = relapses.filter { relapse in
                let date = relapse.date
                return date >= weekStart && date < weekEnd
            }.count
            return RelapseBucket(periodStart: weekStart, count: count)
        }
    }
}
