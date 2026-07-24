import Foundation

/// Eine einzelne Aufgabe des Recovery-Plans mit ihrem heutigen Zustand.
/// Reine Domain-Entität ohne UI-Bezug.
struct RecoveryTask: Identifiable, Equatable {
    let type: RecoveryTaskType
    /// Ob die Aufgabe für den aktuellen Tag abgehakt wurde.
    var isCompleted: Bool

    var id: String { type.rawValue }
}

/// Der Recovery-Plan eines Tages: die Aufgaben plus abgeleiteter Fortschritt.
/// Reine Domain-Entität – die Aufbereitung erfolgt im ViewModel.
struct RecoveryPlan: Equatable {
    /// Tag, für den der Plan gilt (auf Tagesbeginn normalisiert).
    let date: Date
    var tasks: [RecoveryTask]

    var completedCount: Int { tasks.filter(\.isCompleted).count }
    var totalCount: Int { tasks.count }

    /// Fortschritt (0–1) über alle Aufgaben.
    var fraction: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }

    var isCompleted: Bool { totalCount > 0 && completedCount == totalCount }
}
