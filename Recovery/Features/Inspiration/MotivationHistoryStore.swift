import Foundation

/// Merkt sich zuletzt gezeigte Motivations-IDs, um Wiederholungen an
/// aufeinanderfolgenden Tagen zu vermeiden.
///
/// Über ein Protokoll abstrahiert (Dependency Inversion). `UserDefaults`
/// genügt, da es sich um eine kleine, gerätelokale Historie handelt.
protocol MotivationHistoryStore {
    /// Zuletzt gezeigte IDs (jüngste zuerst).
    func recentIds() -> [String]
    /// Vermerkt eine neu gezeigte ID.
    func record(_ id: String)
}

final class UserDefaultsMotivationHistoryStore: MotivationHistoryStore {

    private let defaults: UserDefaults
    private let key = "recovery.motivationHistory"
    /// Wie viele IDs zur Wiederholungsvermeidung vorgehalten werden.
    private let maxCount: Int

    init(defaults: UserDefaults = .standard, maxCount: Int = 7) {
        self.defaults = defaults
        self.maxCount = maxCount
    }

    func recentIds() -> [String] {
        defaults.stringArray(forKey: key) ?? []
    }

    func record(_ id: String) {
        var ids = recentIds()
        ids.removeAll { $0 == id }
        ids.insert(id, at: 0)
        if ids.count > maxCount {
            ids = Array(ids.prefix(maxCount))
        }
        defaults.set(ids, forKey: key)
    }
}
