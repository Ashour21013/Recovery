import Foundation
import SwiftData

/// SwiftData-Persistenzmodell eines freigeschalteten Achievements.
///
/// Es werden nur freigeschaltete Achievements gespeichert; der gesperrte
/// Zustand ergibt sich aus dem Fehlen eines Eintrags.
@Model
final class AchievementModel {
    /// Roh-Wert von `AchievementType`.
    ///
    /// Nicht mehr global unique: Achievements gelten pro Sucht, dieselbe Typ-ID
    /// kann daher für mehrere Süchte existieren (je einmal pro Profil).
    var typeRawValue: String
    var unlockedAt: Date
    /// Zugehörige Sucht (Profil-ID). Optional → leichtgewichtige Migration.
    var profileID: UUID?

    init(typeRawValue: String, unlockedAt: Date, profileID: UUID? = nil) {
        self.typeRawValue = typeRawValue
        self.unlockedAt = unlockedAt
        self.profileID = profileID
    }
}
