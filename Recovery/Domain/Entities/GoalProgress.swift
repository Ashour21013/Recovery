import Foundation

/// Aufbereiteter Ziel-Fortschritt für die Anzeige. Reine Domain-Entität.
struct GoalProgress: Equatable {
    let goal: RecoveryGoal
    let currentDays: Int

    var fraction: Double { goal.fraction(currentDays: currentDays) }
    var isAchieved: Bool { goal.isAchieved(currentDays: currentDays) }
    var remainingDays: Int { goal.remainingDays(currentDays: currentDays) }
}
