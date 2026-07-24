import Foundation

/// Aggregiertes Modell für den Dashboard-Screen.
///
/// Bündelt alle Informationen, die das Dashboard darstellt. Die Domain
/// bleibt frei von UI-Details; die Aufbereitung übernimmt das ViewModel.
struct DashboardData: Equatable {
    let habitType: HabitType
    let streak: Streak
    let quote: MotivationalQuote
    let progress: ProgressSummary
    let dailyGoal: DailyGoal
    /// Fortschritt des gewählten Ziels (falls eines gesetzt ist).
    let goalProgress: GoalProgress?
    /// Täglicher Recovery-Plan mit abhakbaren Aufgaben.
    var plan: RecoveryPlan
}
