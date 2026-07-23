import Foundation

/// Tagesziel des Nutzers, das aus mehreren Teilaufgaben besteht.
/// Reine Domain-Entität ohne UI-Bezug.
struct DailyGoal: Equatable {
    let title: String
    /// Bereits erledigte Teilaufgaben.
    let completedTasks: Int
    /// Insgesamt zu erledigende Teilaufgaben.
    let totalTasks: Int

    /// Fortschritt zwischen 0.0 und 1.0.
    var fraction: Double {
        guard totalTasks > 0 else { return 0 }
        return min(1.0, Double(completedTasks) / Double(totalTasks))
    }

    var isCompleted: Bool { completedTasks >= totalTasks && totalTasks > 0 }
}
