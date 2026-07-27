import Foundation
import SwiftData

/// SwiftData-Persistenzmodell für das Recovery-Profil.
///
/// Gehört zur Data-Schicht. Wird auf die Domain-Entität `RecoveryProfile`
/// gemappt, damit die Domain unabhängig von SwiftData bleibt. Journal,
/// Trigger und Rückfälle hängen über Beziehungen am Profil.
@Model
final class RecoveryProfileModel {
    @Attribute(.unique) var id: UUID
    /// Roh-Wert von `HabitType`.
    var habitTypeRawValue: String
    var reason: String
    /// Roh-Wert von `HabitFrequency` (optional).
    var frequencyRawValue: String?
    var startDate: Date
    var bestStreakDays: Int
    /// Gewähltes Ziel in Tagen (optional → leichtgewichtige Migration).
    var goalDays: Int?
    /// Gewählte Motivationsquelle (Roh-Wert, optional → leichte Migration).
    var motivationSourceRawValue: String?

    /// Ob diese Sucht aktuell die aktive (im Dashboard angezeigte) ist.
    /// Optional-defaultend, damit Bestandsdaten leichtgewichtig migrieren.
    var isActive: Bool = false

    @Relationship(deleteRule: .cascade, inverse: \JournalEntryModel.profile)
    var journalEntries: [JournalEntryModel]

    @Relationship(deleteRule: .cascade, inverse: \TriggerModel.profile)
    var triggers: [TriggerModel]

    @Relationship(deleteRule: .cascade, inverse: \RelapseModel.profile)
    var relapses: [RelapseModel]

    @Relationship(deleteRule: .cascade, inverse: \PlanTaskCompletionModel.profile)
    var planCompletions: [PlanTaskCompletionModel]

    @Relationship(deleteRule: .cascade, inverse: \PlanTaskModel.profile)
    var planTasks: [PlanTaskModel]

    init(
        id: UUID,
        habitTypeRawValue: String,
        reason: String,
        frequencyRawValue: String?,
        startDate: Date,
        bestStreakDays: Int,
        goalDays: Int? = nil,
        motivationSourceRawValue: String? = nil,
        isActive: Bool = false
    ) {
        self.id = id
        self.habitTypeRawValue = habitTypeRawValue
        self.reason = reason
        self.frequencyRawValue = frequencyRawValue
        self.startDate = startDate
        self.bestStreakDays = bestStreakDays
        self.goalDays = goalDays
        self.motivationSourceRawValue = motivationSourceRawValue
        self.isActive = isActive
        self.journalEntries = []
        self.triggers = []
        self.relapses = []
        self.planCompletions = []
        self.planTasks = []
    }
}
