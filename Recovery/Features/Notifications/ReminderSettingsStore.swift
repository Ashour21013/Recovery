import Foundation

/// Persistiert die Erinnerungs-Einstellungen.
///
/// Bewusst über ein Protokoll abstrahiert. `UserDefaults` genügt hier, da es
/// sich um eine kleine, gerätelokale Präferenz handelt (kein SwiftData nötig).
protocol ReminderSettingsStore {
    func load() -> ReminderSettings
    func save(_ settings: ReminderSettings)
}

final class UserDefaultsReminderSettingsStore: ReminderSettingsStore {

    private let defaults: UserDefaults
    private let key = "recovery.reminderSettings"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> ReminderSettings {
        guard
            let data = defaults.data(forKey: key),
            let settings = try? JSONDecoder().decode(ReminderSettings.self, from: data)
        else {
            return .default
        }
        return settings
    }

    func save(_ settings: ReminderSettings) {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        defaults.set(data, forKey: key)
    }
}
