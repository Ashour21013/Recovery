import Foundation

/// Persistierbares Profil einer Recovery-Reise. Reine Domain-Entität.
///
/// Enthält die im Onboarding gewählte Sucht sowie das Startdatum, aus dem
/// die aktuelle Streak berechnet wird. `bestStreakDays` hält den bisherigen
/// Rekord fest (auch über Rückfälle hinweg).
struct RecoveryProfile: Equatable, Identifiable {
    let id: UUID
    var habitType: HabitType
    var reason: String
    var frequency: HabitFrequency?
    /// Beginn der aktuellen Strähne (wird bei Rückfall zurückgesetzt).
    var startDate: Date
    /// Bisher längste erreichte Strähne in Tagen.
    var bestStreakDays: Int
    /// Aktuell gewähltes Ziel (in Tagen), falls gesetzt.
    var goalDays: Int?
    /// Gewählte Quelle der täglichen Motivation.
    var motivationSource: MotivationSource

    init(
        id: UUID = UUID(),
        habitType: HabitType,
        reason: String = "",
        frequency: HabitFrequency? = nil,
        startDate: Date = .now,
        bestStreakDays: Int = 0,
        goalDays: Int? = nil,
        motivationSource: MotivationSource = .default
    ) {
        self.id = id
        self.habitType = habitType
        self.reason = reason
        self.frequency = frequency
        self.startDate = startDate
        self.bestStreakDays = bestStreakDays
        self.goalDays = goalDays
        self.motivationSource = motivationSource
    }

    /// Typsicherer Zugriff auf das gewählte Ziel.
    var goal: RecoveryGoal? {
        get { goalDays.flatMap(RecoveryGoal.init(rawValue:)) }
        set { goalDays = newValue?.rawValue }
    }

    /// Anzahl cleaner Tage seit `startDate` (kalendarisch, nie negativ).
    func currentStreakDays(now: Date = .now, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: startDate)
        let today = calendar.startOfDay(for: now)
        let days = calendar.dateComponents([.day], from: start, to: today).day ?? 0
        return max(0, days)
    }

    /// Leitet die `Streak`-Entität aus Startdatum und Rekord ab.
    func streak(now: Date = .now, calendar: Calendar = .current) -> Streak {
        let current = currentStreakDays(now: now, calendar: calendar)
        return Streak(
            currentDays: current,
            bestDays: max(bestStreakDays, current),
            startedAt: startDate
        )
    }
}
