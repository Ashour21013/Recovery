import Foundation
import SwiftData

/// SwiftData-basierte Implementierung von `AchievementService`.
///
/// Speichert nur freigeschaltete Achievements. Beim Auswerten werden neu
/// erfüllte Typen persistiert und zurückgegeben (für die Freischalt-Animation).
@MainActor
final class SwiftDataAchievementService: AchievementService {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func allAchievements() async -> [Achievement] {
        let unlocked = fetchUnlockedMap()
        return AchievementType.allCases.map { type in
            Achievement(type: type, unlockedAt: unlocked[type.rawValue])
        }
    }

    @discardableResult
    func evaluate(_ evaluationContext: AchievementContext) async -> [Achievement] {
        let profileID = activeProfileID()
        let unlocked = fetchUnlockedMap()
        var newlyUnlocked: [Achievement] = []
        let now = Date.now

        for type in AchievementType.allCases {
            let alreadyUnlocked = unlocked[type.rawValue] != nil
            guard !alreadyUnlocked, AchievementRules.isSatisfied(type, in: evaluationContext) else {
                continue
            }
            let model = AchievementModel(typeRawValue: type.rawValue, unlockedAt: now, profileID: profileID)
            context.insert(model)
            newlyUnlocked.append(Achievement(type: type, unlockedAt: now))
        }

        if !newlyUnlocked.isEmpty {
            try? context.save()
        }
        return newlyUnlocked
    }

    // MARK: - Private

    /// Achievements gelten pro aktiver Sucht: nur Einträge der aktiven (bzw.
    /// noch nicht zugeordneter Alt-Einträge) berücksichtigen.
    private func fetchUnlockedMap() -> [String: Date] {
        let activeID = activeProfileID()
        let descriptor = FetchDescriptor<AchievementModel>()
        let models = (try? context.fetch(descriptor)) ?? []
        let scoped = models.filter { $0.profileID == activeID || $0.profileID == nil }
        return Dictionary(models: scoped)
    }

    /// Ermittelt die ID der aktuell aktiven Sucht (oder der ersten vorhandenen).
    private func activeProfileID() -> UUID? {
        let profiles = (try? context.fetch(FetchDescriptor<RecoveryProfileModel>())) ?? []
        return (profiles.first(where: { $0.isActive }) ?? profiles.first)?.id
    }
}

private extension Dictionary where Key == String, Value == Date {
    /// Baut eine Typ→Datum-Map, wobei bei Duplikaten das frühere Datum gewinnt.
    init(models: [AchievementModel]) {
        self = models.reduce(into: [:]) { map, model in
            if let existing = map[model.typeRawValue] {
                map[model.typeRawValue] = Swift.min(existing, model.unlockedAt)
            } else {
                map[model.typeRawValue] = model.unlockedAt
            }
        }
    }
}
