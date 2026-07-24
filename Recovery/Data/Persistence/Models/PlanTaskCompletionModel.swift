import Foundation
import SwiftData

/// SwiftData-Persistenzmodell für den Abschluss einer Plan-Aufgabe an einem
/// bestimmten Tag (Data-Schicht).
///
/// Es wird nur gespeichert, wenn eine Aufgabe abgehakt wurde. Der offene
/// Zustand ergibt sich aus dem Fehlen eines Eintrags für den Tag.
@Model
final class PlanTaskCompletionModel {
    /// Roh-Wert von `RecoveryTaskType`.
    var taskRawValue: String
    /// Tag (auf Tagesbeginn normalisiert), an dem abgehakt wurde.
    var day: Date
    var completedAt: Date
    var profile: RecoveryProfileModel?

    init(taskRawValue: String, day: Date, completedAt: Date) {
        self.taskRawValue = taskRawValue
        self.day = day
        self.completedAt = completedAt
    }
}
