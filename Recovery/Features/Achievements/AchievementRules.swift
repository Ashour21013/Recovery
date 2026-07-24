import Foundation

/// Enthält die Regeln, wann ein Achievement als erfüllt gilt.
/// Reine, zustandslose Logik – dadurch leicht testbar und wiederverwendbar.
enum AchievementRules {

    /// Prüft, ob der gegebene Kontext das Achievement erfüllt.
    static func isSatisfied(_ type: AchievementType, in context: AchievementContext) -> Bool {
        switch type {
        case .first24Hours:
            return context.hoursSinceStart >= 24
        case .threeDays:
            return context.currentStreakDays >= 3
        case .sevenDays:
            return context.currentStreakDays >= 7
        case .thirtyDays:
            return context.currentStreakDays >= 30
        case .ninetyDays:
            return context.currentStreakDays >= 90
        case .oneYear:
            return context.currentStreakDays >= 365
        case .firstJournal:
            return context.journalCount >= 1
        case .tenJournals:
            return context.journalCount >= 10
        case .firstCraving:
            return context.completedCravingSessions >= 1
        case .firstWeekNoRelapse:
            // Kein Rückfall bei mindestens 7 cleanen Tagen.
            return context.relapseCount == 0 && context.currentStreakDays >= 7
        }
    }
}
