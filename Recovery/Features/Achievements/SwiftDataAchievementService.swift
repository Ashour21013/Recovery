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
        let unlocked = fetchUnlockedMap()
        var newlyUnlocked: [Achievement] = []
        let now = Date.now

        for type in AchievementType.allCases {
            let alreadyUnlocked = unlocked[type.rawValue] != nil
            guard !alreadyUnlocked, AchievementRules.isSatisfied(type, in: evaluationContext) else {
                continue
            }
            let model = AchievementModel(typeRawValue: type.rawValue, unlockedAt: now)
            context.insert(model)
            newlyUnlocked.append(Achievement(type: type, unlockedAt: now))
        }

        if !newlyUnlocked.isEmpty {
            try? context.save()
        }
        return newlyUnlocked
    }

    // MARK: - Private

    private func fetchUnlockedMap() -> [String: Date] {
        let descriptor = FetchDescriptor<AchievementModel>()
        let models = (try? context.fetch(descriptor)) ?? []
        return Dictionary(uniqueKeysWithValues: models.map { ($0.typeRawValue, $0.unlockedAt) })
    }
}
