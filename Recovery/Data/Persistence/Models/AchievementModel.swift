import Foundation
import SwiftData

/// SwiftData-Persistenzmodell eines freigeschalteten Achievements.
///
/// Es werden nur freigeschaltete Achievements gespeichert; der gesperrte
/// Zustand ergibt sich aus dem Fehlen eines Eintrags.
@Model
final class AchievementModel {
    /// Roh-Wert von `AchievementType` (eindeutig – jedes nur einmal).
    @Attribute(.unique) var typeRawValue: String
    var unlockedAt: Date

    init(typeRawValue: String, unlockedAt: Date) {
        self.typeRawValue = typeRawValue
        self.unlockedAt = unlockedAt
    }
}
