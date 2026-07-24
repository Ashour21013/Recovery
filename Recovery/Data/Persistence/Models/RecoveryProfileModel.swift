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

    @Relationship(deleteRule: .cascade, inverse: \JournalEntryModel.profile)
    var journalEntries: [JournalEntryModel]

    @Relationship(deleteRule: .cascade, inverse: \TriggerModel.profile)
    var triggers: [TriggerModel]

    @Relationship(deleteRule: .cascade, inverse: \RelapseModel.profile)
    var relapses: [RelapseModel]

    init(
        id: UUID,
        habitTypeRawValue: String,
        reason: String,
        frequencyRawValue: String?,
        startDate: Date,
        bestStreakDays: Int,
        goalDays: Int? = nil
    ) {
        self.id = id
        self.habitTypeRawValue = habitTypeRawValue
        self.reason = reason
        self.frequencyRawValue = frequencyRawValue
        self.startDate = startDate
        self.bestStreakDays = bestStreakDays
        self.goalDays = goalDays
        self.journalEntries = []
        self.triggers = []
        self.relapses = []
    }
}
