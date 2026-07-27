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
        do {
            guard let model = try activeProfileModelIfExists() else { return nil }
            return RecoveryMapper.toDomain(model)
        } catch {
            throw AppError.persistence
        }
    }

    @discardableResult
    func createProfile(_ profile: RecoveryProfile) async throws -> RecoveryProfile {
        let model = RecoveryMapper.makeModel(from: profile)
        // Erste Sucht wird automatisch aktiv.
        let hasAny = try !allProfileModels().isEmpty
        model.isActive = !hasAny
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

    func updateMotivationSource(_ source: MotivationSource) async throws {
        let model = try currentProfileModel()
        model.motivationSourceRawValue = source.rawValue
        try save()
    }

    // MARK: - Fortschritts-Metriken

    func fetchMetrics() async throws -> AddictionMetrics {
        let model = try currentProfileModel()
        return RecoveryMapper.metrics(from: model)
    }

    func updateMetrics(_ metrics: AddictionMetrics) async throws {
        let model = try currentProfileModel()
        RecoveryMapper.apply(metrics, to: model)
        try save()
    }

    // MARK: - Süchte (Multi-Addiction)

    func fetchAddictions() async throws -> [AddictionSummary] {
        do {
            try ensureActiveAddiction()
            let models = try allProfileModels()
            return models
                .map { model in
                    let domain = RecoveryMapper.toDomain(model)
                    return AddictionSummary(
                        id: model.id,
                        habitType: domain.habitType,
                        currentStreakDays: domain.currentStreakDays(),
                        bestStreakDays: model.bestStreakDays,
                        isActive: model.isActive
                    )
                }
                .sorted { $0.title < $1.title }
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.persistence
        }
    }

    @discardableResult
    func addAddiction(_ profile: RecoveryProfile) async throws -> RecoveryProfile {
        try await createProfile(profile)
    }

    func switchAddiction(to id: UUID) async throws {
        do {
            let models = try allProfileModels()
            guard models.contains(where: { $0.id == id }) else {
                throw AppError.notFound
            }
            for model in models {
                model.isActive = (model.id == id)
            }
            try save()
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.persistence
        }
    }

    func deleteAddiction(id: UUID) async throws {
        do {
            let models = try allProfileModels()
            guard let target = models.first(where: { $0.id == id }) else {
                throw AppError.notFound
            }
            let wasActive = target.isActive
            context.delete(target)

            // War die gelöschte Sucht aktiv, eine andere aktiv setzen.
            if wasActive {
                let remaining = models.filter { $0.id != id }
                remaining.first?.isActive = true
            }
            try save()
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.persistence
        }
    }

    // MARK: - Journal

    func fetchJournalEntries() async throws -> [JournalEntry] {
        let profileId = try currentProfileModel().id
        let descriptor = FetchDescriptor<JournalEntryModel>(
            predicate: #Predicate { $0.profile?.id == profileId },
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
        let profileId = try currentProfileModel().id
        let descriptor = FetchDescriptor<TriggerModel>(
            predicate: #Predicate { $0.profile?.id == profileId },
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
        let profileId = try currentProfileModel().id
        let descriptor = FetchDescriptor<RelapseModel>(
            predicate: #Predicate { $0.profile?.id == profileId },
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

    // MARK: - Recovery-Plan

    func fetchPlan(for day: Date) async throws -> RecoveryPlan {
        let normalizedDay = Calendar.current.startOfDay(for: day)
        do {
            let definition = try planDefinition()
            let profileId = try currentProfileModel().id

            let completionDescriptor = FetchDescriptor<PlanTaskCompletionModel>(
                predicate: #Predicate { $0.day == normalizedDay && $0.profile?.id == profileId }
            )
            let completions = try context.fetch(completionDescriptor)
            let completedIds = Set(completions.map(\.taskRawValue))

            let tasks = definition.map { task in
                RecoveryTask(task: task, isCompleted: completedIds.contains(task.id))
            }
            return RecoveryPlan(date: normalizedDay, tasks: tasks)
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.persistence
        }
    }

    func setTaskCompletion(_ taskId: String, on day: Date, isCompleted: Bool) async throws {
        let normalizedDay = Calendar.current.startOfDay(for: day)
        do {
            let profileId = try currentProfileModel().id
            var descriptor = FetchDescriptor<PlanTaskCompletionModel>(
                predicate: #Predicate { $0.day == normalizedDay && $0.taskRawValue == taskId && $0.profile?.id == profileId }
            )
            descriptor.fetchLimit = 1
            let existing = try context.fetch(descriptor).first

            if isCompleted {
                guard existing == nil else { return }
                let model = PlanTaskCompletionModel(
                    taskRawValue: taskId,
                    day: normalizedDay,
                    completedAt: .now
                )
                model.profile = try currentProfileModel()
                context.insert(model)
            } else if let existing {
                context.delete(existing)
            }
            try save()
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.persistence
        }
    }

    func fetchPlanTasks() async throws -> [PlanTask] {
        do {
            return try planDefinition()
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.persistence
        }
    }

    func addPlanTask(_ task: PlanTask) async throws {
        do {
            let existing = try fetchPlanTaskModels()
            // Doppelte (gleiche id) vermeiden.
            guard !existing.contains(where: { $0.id == task.id }) else { return }
            let nextOrder = (existing.map(\.order).max() ?? -1) + 1
            let model = PlanTaskModel(
                id: task.id,
                title: task.title,
                subtitle: task.subtitle,
                systemImage: task.systemImage,
                isCustom: task.isCustom,
                order: nextOrder
            )
            model.profile = try currentProfileModel()
            context.insert(model)
            try save()
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.persistence
        }
    }

    func removePlanTask(id: String) async throws {
        do {
            let profileId = try currentProfileModel().id
            var descriptor = FetchDescriptor<PlanTaskModel>(
                predicate: #Predicate { $0.id == id && $0.profile?.id == profileId }
            )
            descriptor.fetchLimit = 1
            if let model = try context.fetch(descriptor).first {
                context.delete(model)
                try save()
            }
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.persistence
        }
    }

    /// Liefert die Plan-Definition und legt bei Bedarf den Standard-Plan an
    /// (Auto-Seeding beim ersten Zugriff nach dem Onboarding).
    private func planDefinition() throws -> [PlanTask] {
        let models = try fetchPlanTaskModels()
        if models.isEmpty {
            return try seedDefaultPlan()
        }
        return models.map(planTask(from:))
    }

    private func fetchPlanTaskModels() throws -> [PlanTaskModel] {
        let profileId = try currentProfileModel().id
        let descriptor = FetchDescriptor<PlanTaskModel>(
            predicate: #Predicate { $0.profile?.id == profileId },
            sortBy: [SortDescriptor(\.order, order: .forward)]
        )
        return try context.fetch(descriptor)
    }

    private func seedDefaultPlan() throws -> [PlanTask] {
        let profile = try currentProfileModel()
        var result: [PlanTask] = []
        for (index, type) in RecoveryTaskType.defaultPlan.enumerated() {
            let task = PlanTask(type)
            let model = PlanTaskModel(
                id: task.id,
                title: task.title,
                subtitle: task.subtitle,
                systemImage: task.systemImage,
                isCustom: false,
                order: index
            )
            model.profile = profile
            context.insert(model)
            result.append(task)
        }
        try save()
        return result
    }

    private func planTask(from model: PlanTaskModel) -> PlanTask {
        PlanTask(
            id: model.id,
            title: model.title,
            subtitle: model.subtitle,
            systemImage: model.systemImage,
            isCustom: model.isCustom
        )
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
            // Objektweises Löschen statt Batch-Delete: Batch-Delete umgeht die
            // SwiftData-Cascade-/Inverse-Regeln und verletzt die verpflichtende
            // Inverse-Beziehung `PlanTaskModel.profile`. Durch das Löschen der
            // einzelnen Objekte (Profil zuletzt) greifen die `.cascade`-Regeln
            // korrekt und Beziehungen werden sauber aufgelöst.
            try deleteEveryObject(of: JournalEntryModel.self)
            try deleteEveryObject(of: TriggerModel.self)
            try deleteEveryObject(of: RelapseModel.self)
            try deleteEveryObject(of: AchievementModel.self)
            try deleteEveryObject(of: PlanTaskCompletionModel.self)
            try deleteEveryObject(of: PlanTaskModel.self)
            try deleteEveryObject(of: RecoveryProfileModel.self)
            try context.save()
        } catch {
            throw AppError.persistence
        }
    }

    /// Löscht alle Objekte des angegebenen Modelltyps einzeln aus dem Kontext.
    private func deleteEveryObject<T: PersistentModel>(of type: T.Type) throws {
        let objects = try context.fetch(FetchDescriptor<T>())
        for object in objects {
            context.delete(object)
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

    /// Liefert das aktuell aktive Profil oder wirft `notFound`.
    private func currentProfileModel() throws -> RecoveryProfileModel {
        do {
            try ensureActiveAddiction()
            guard let model = try activeProfileModelIfExists() else {
                throw AppError.notFound
            }
            return model
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.persistence
        }
    }

    /// Alle Profile (Süchte), unsortiert.
    private func allProfileModels() throws -> [RecoveryProfileModel] {
        try context.fetch(FetchDescriptor<RecoveryProfileModel>())
    }

    /// Das aktive Profil, falls vorhanden – ohne Seiteneffekte.
    private func activeProfileModelIfExists() throws -> RecoveryProfileModel? {
        let models = try allProfileModels()
        return models.first(where: { $0.isActive }) ?? models.first
    }

    /// Stellt sicher, dass genau eine Sucht aktiv ist (Migration/Selbstheilung).
    ///
    /// Für Bestandsdaten (eine Sucht ohne `isActive`) wird diese aktiv gesetzt.
    /// Sollten aus irgendeinem Grund mehrere aktiv sein, bleibt nur die erste.
    private func ensureActiveAddiction() throws {
        let models = try allProfileModels()
        guard !models.isEmpty else { return }

        let active = models.filter { $0.isActive }
        if active.isEmpty {
            models.first?.isActive = true
            try context.save()
        } else if active.count > 1 {
            for model in active.dropFirst() { model.isActive = false }
            try context.save()
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
