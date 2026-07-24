import Foundation
import Observation

/// ViewModel für die Konfiguration der Erinnerungen (MVVM).
///
/// Verwaltet die aktivierten Tageszeiten, kümmert sich um die Berechtigung
/// und plant die Benachrichtigungen über den `NotificationService`. Kennt
/// keine Framework-Details (`UserNotifications`).
@MainActor
@Observable
final class ReminderSettingsViewModel: ViewModel {

    private(set) var settings: ReminderSettings
    /// `true`, wenn die Benachrichtigungsberechtigung verweigert wurde.
    private(set) var isPermissionDenied = false

    private let service: NotificationService
    private let store: ReminderSettingsStore

    init(service: NotificationService, store: ReminderSettingsStore) {
        self.service = service
        self.store = store
        self.settings = store.load()
    }

    func onAppear() async {
        isPermissionDenied = !(await service.isAuthorized()) && !settings.enabledTimes.isEmpty
    }

    func isEnabled(_ time: ReminderTime) -> Bool {
        settings.isEnabled(time)
    }

    /// Schaltet eine Tageszeit um und aktualisiert die geplanten Erinnerungen.
    func toggle(_ time: ReminderTime) async {
        if settings.enabledTimes.contains(time) {
            settings.enabledTimes.remove(time)
        } else {
            // Vor dem ersten Aktivieren Berechtigung sicherstellen.
            let granted = await ensureAuthorization()
            guard granted else {
                isPermissionDenied = true
                return
            }
            settings.enabledTimes.insert(time)
        }

        store.save(settings)
        await service.scheduleReminders(settings)
    }

    private func ensureAuthorization() async -> Bool {
        if await service.isAuthorized() { return true }
        return await service.requestAuthorization()
    }
}
