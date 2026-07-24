import Foundation
import SwiftData

/// SwiftData-basierte Implementierung von `RecoveryRepository`.
///
/// Kapselt sämtliche Persistenzlogik. Läuft auf dem `@MainActor`, da der
/// verwendete `ModelContext` an den Main-Kontext des `ModelContainer`
/// gebunden ist. Technische Fehler werden auf `AppError` gemappt.
@MainActor
final class SwiftDataRecoveryRepository: RecoveryRepository {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Profil

    func loadProfile() async throws -> RecoveryProfile? {
        let descriptor = FetchDescriptor<RecoveryProfileModel>()
        do {
            guard let model = try context.fetch(descriptor).first else { return nil }
            return RecoveryMapper.toDomain(model)
        } catch {
            throw AppError.persistence
        }
    }

    @discardableResult
    func createProfile(_ profile: RecoveryProfile) async throws -> RecoveryProfile {
        let model = RecoveryMapper.makeModel(from: profile)
        context.insert(model)
        try save()
        return RecoveryMapper.toDomain(model)
    }

    func updateProfile(_ profile: RecoveryProfile) async throws {
        let model = try fetchProfileModel(id: profile.id)
        RecoveryMapper.apply(profile, to: model)
        try save()
    }

    func updateGoal(_ goal: RecoveryGoal?) async throws {
        let model = try currentProfileModel()
        model.goalDays = goal?.rawValue
        try save()
    }

    // MARK: - Journal

    func fetchJournalEntries() async throws -> [JournalEntry] {
        let descriptor = FetchDescriptor<JournalEntryModel>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try fetchMapped(descriptor, RecoveryMapper.toDomain)
    }

    func addJournalEntry(_ entry: JournalEntry) async throws {
        let model = RecoveryMapper.makeModel(from: entry)
        model.profile = try currentProfileModel()
        context.insert(model)
        try save()
    }

    func deleteJournalEntry(id: UUID) async throws {
        var descriptor = FetchDescriptor<JournalEntryModel>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        try deleteFirst(descriptor)
    }

    // MARK: - Trigger

    func fetchTriggers() async throws -> [Trigger] {
        let descriptor = FetchDescriptor<TriggerModel>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try fetchMapped(descriptor, RecoveryMapper.toDomain)
    }

    func addTrigger(_ trigger: Trigger) async throws {
        let model = RecoveryMapper.makeModel(from: trigger)
        model.profile = try currentProfileModel()
        context.insert(model)
        try save()
    }

    func deleteTrigger(id: UUID) async throws {
        var descriptor = FetchDescriptor<TriggerModel>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        try deleteFirst(descriptor)
    }

    // MARK: - Rückfälle

    func fetchRelapses() async throws -> [Relapse] {
        let descriptor = FetchDescriptor<RelapseModel>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try fetchMapped(descriptor, RecoveryMapper.toDomain)
    }

    func recordRelapse(_ relapse: Relapse) async throws {
        let profile = try currentProfileModel()

        // Rückfall dokumentieren.
        let model = RecoveryMapper.makeModel(from: relapse)
        model.profile = profile
        context.insert(model)

        // Journal automatisch mit einem Eintrag aktualisieren, damit der
        // Rückfall auch im Tagebuch und in den Trigger-Statistiken auftaucht.
        let journalEntry = JournalEntryModel(
            id: UUID(),
            date: relapse.date,
            text: relapseJournalText(for: relapse),
            mood: Mood.bad.rawValue,
            triggerName: relapse.triggerNames.first
        )
        journalEntry.profile = profile
        context.insert(journalEntry)

        // Bisherige Strähne als Rekord sichern und Streak zurücksetzen.
        let domain = RecoveryMapper.toDomain(profile)
        let achieved = domain.currentStreakDays(now: relapse.date)
        profile.bestStreakDays = max(profile.bestStreakDays, achieved)
        profile.startDate = Calendar.current.startOfDay(for: relapse.date)

        try save()
    }

    // MARK: - Datenverwaltung

    func exportData() async throws -> ExportData {
        do {
            let profileModel = try context.fetch(FetchDescriptor<RecoveryProfileModel>()).first
            let journal = try context.fetch(
                FetchDescriptor<JournalEntryModel>(sortBy: [SortDescriptor(\.date, order: .reverse)])
            )
            let triggers = try context.fetch(
                FetchDescriptor<TriggerModel>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            )
            let relapses = try context.fetch(
                FetchDescriptor<RelapseModel>(sortBy: [SortDescriptor(\.date, order: .reverse)])
            )

            return ExportData(
                exportedAt: .now,
                appVersion: AppInfo.fullVersion,
                profile: profileModel.map { model in
                    ExportData.ProfileExport(
                        habitType: model.habitTypeRawValue,
                        reason: model.reason,
                        frequency: model.frequencyRawValue,
                        startDate: model.startDate,
                        bestStreakDays: model.bestStreakDays,
                        goalDays: model.goalDays
                    )
                },
                journalEntries: journal.map {
                    ExportData.JournalEntryExport(
                        date: $0.date,
                        text: $0.text,
                        mood: $0.mood,
                        triggerName: $0.triggerName
                    )
                },
                triggers: triggers.map {
                    ExportData.TriggerExport(name: $0.name, note: $0.note, createdAt: $0.createdAt)
                },
                relapses: relapses.map {
                    ExportData.RelapseExport(
                        date: $0.date,
                        note: $0.note,
                        cravingIntensity: $0.cravingIntensity,
                        triggerNames: $0.triggerNames
                    )
                }
            )
        } catch {
            throw AppError.persistence
        }
    }

    func deleteAllData() async throws {
        do {
            try context.delete(model: JournalEntryModel.self)
            try context.delete(model: TriggerModel.self)
            try context.delete(model: RelapseModel.self)
            try context.delete(model: AchievementModel.self)
            try context.delete(model: RecoveryProfileModel.self)
            try context.save()
        } catch {
            throw AppError.persistence
        }
    }

    /// Baut einen kurzen Journal-Text aus den Rückfall-Details.
    private func relapseJournalText(for relapse: Relapse) -> String {
        var parts = ["Rückfall dokumentiert."]
        parts.append("Verlangen: \(relapse.cravingIntensity)/10.")
        if !relapse.triggerNames.isEmpty {
            parts.append("Trigger: \(relapse.triggerNames.joined(separator: ", ")).")
        }
        if !relapse.note.isEmpty {
            parts.append(relapse.note)
        }
        return parts.joined(separator: " ")
    }

    // MARK: - Private Helpers

    private func fetchProfileModel(id: UUID) throws -> RecoveryProfileModel {
        var descriptor = FetchDescriptor<RecoveryProfileModel>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        do {
            guard let model = try context.fetch(descriptor).first else {
                throw AppError.notFound
            }
            return model
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.persistence
        }
    }

    /// Liefert das (einzige) aktuelle Profil oder wirft `notFound`.
    private func currentProfileModel() throws -> RecoveryProfileModel {
        var descriptor = FetchDescriptor<RecoveryProfileModel>()
        descriptor.fetchLimit = 1
        do {
            guard let model = try context.fetch(descriptor).first else {
                throw AppError.notFound
            }
            return model
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.persistence
        }
    }

    private func fetchMapped<Model, DomainType>(
        _ descriptor: FetchDescriptor<Model>,
        _ transform: (Model) -> DomainType
    ) throws -> [DomainType] {
        do {
            return try context.fetch(descriptor).map(transform)
        } catch {
            throw AppError.persistence
        }
    }

    /// Löscht das erste Modell, das zum Descriptor passt (falls vorhanden).
    private func deleteFirst<Model: PersistentModel>(_ descriptor: FetchDescriptor<Model>) throws {
        do {
            if let model = try context.fetch(descriptor).first {
                context.delete(model)
                try context.save()
            }
        } catch {
            throw AppError.persistence
        }
    }

    private func save() throws {
        do {
            try context.save()
        } catch {
            throw AppError.persistence
        }
    }
}
