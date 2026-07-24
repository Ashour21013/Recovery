import Foundation

/// Mapping zwischen SwiftData-Persistenzmodellen und Domain-Entities.
///
/// Kapselt die Übersetzung in beide Richtungen, damit die Domain frei von
/// Persistenzdetails bleibt (Single Responsibility).
enum RecoveryMapper {

    // MARK: - Profil

    static func toDomain(_ model: RecoveryProfileModel) -> RecoveryProfile {
        RecoveryProfile(
            id: model.id,
            habitType: HabitType(rawValue: model.habitTypeRawValue) ?? .smoking,
            reason: model.reason,
            frequency: model.frequencyRawValue.flatMap(HabitFrequency.init(rawValue:)),
            startDate: model.startDate,
            bestStreakDays: model.bestStreakDays
        )
    }

    static func makeModel(from profile: RecoveryProfile) -> RecoveryProfileModel {
        RecoveryProfileModel(
            id: profile.id,
            habitTypeRawValue: profile.habitType.rawValue,
            reason: profile.reason,
            frequencyRawValue: profile.frequency?.rawValue,
            startDate: profile.startDate,
            bestStreakDays: profile.bestStreakDays
        )
    }

    static func apply(_ profile: RecoveryProfile, to model: RecoveryProfileModel) {
        model.habitTypeRawValue = profile.habitType.rawValue
        model.reason = profile.reason
        model.frequencyRawValue = profile.frequency?.rawValue
        model.startDate = profile.startDate
        model.bestStreakDays = profile.bestStreakDays
    }

    // MARK: - Journal

    static func toDomain(_ model: JournalEntryModel) -> JournalEntry {
        JournalEntry(
            id: model.id,
            date: model.date,
            text: model.text,
            mood: model.mood,
            triggerName: model.triggerName
        )
    }

    static func makeModel(from entry: JournalEntry) -> JournalEntryModel {
        JournalEntryModel(
            id: entry.id,
            date: entry.date,
            text: entry.text,
            mood: entry.mood,
            triggerName: entry.triggerName
        )
    }

    // MARK: - Trigger

    static func toDomain(_ model: TriggerModel) -> Trigger {
        Trigger(id: model.id, name: model.name, note: model.note, createdAt: model.createdAt)
    }

    static func makeModel(from trigger: Trigger) -> TriggerModel {
        TriggerModel(id: trigger.id, name: trigger.name, note: trigger.note, createdAt: trigger.createdAt)
    }

    // MARK: - Rückfälle

    static func toDomain(_ model: RelapseModel) -> Relapse {
        Relapse(
            id: model.id,
            date: model.date,
            note: model.note,
            cravingIntensity: model.cravingIntensity,
            triggerNames: model.triggerNames
        )
    }

    static func makeModel(from relapse: Relapse) -> RelapseModel {
        RelapseModel(
            id: relapse.id,
            date: relapse.date,
            note: relapse.note,
            cravingIntensity: relapse.cravingIntensity,
            triggerNames: relapse.triggerNames
        )
    }
}
