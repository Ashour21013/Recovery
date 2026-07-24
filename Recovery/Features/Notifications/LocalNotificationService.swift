import Foundation
import UserNotifications

/// Konkrete Implementierung von `NotificationService` mit Apples
/// `UserNotifications`-Framework. Plant wiederkehrende, lokale
/// Kalender-Benachrichtigungen für die gewählten Tageszeiten.
final class LocalNotificationService: NotificationService {

    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func isAuthorized() async -> Bool {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        default:
            return false
        }
    }

    func scheduleReminders(_ settings: ReminderSettings) async {
        await cancelAllReminders()

        for time in settings.enabledTimes {
            let content = makeContent(for: time)
            let trigger = makeTrigger(for: time)
            let request = UNNotificationRequest(
                identifier: time.identifier,
                content: content,
                trigger: trigger
            )
            try? await center.add(request)
        }
    }

    func cancelAllReminders() async {
        let identifiers = ReminderTime.allCases.map(\.identifier)
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    // MARK: - Private

    private func makeContent(for time: ReminderTime) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Recovery"
        content.body = NotificationMessageProvider.message(seed: time.defaultHour)
        content.sound = .default
        return content
    }

    /// Täglich wiederkehrender Kalender-Trigger zur Standardstunde.
    private func makeTrigger(for time: ReminderTime) -> UNCalendarNotificationTrigger {
        var components = DateComponents()
        components.hour = time.defaultHour
        components.minute = 0
        return UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
    }
}
