import Foundation
import UserNotifications

/// Delegate, damit Benachrichtigungen auch im Vordergrund als Banner
/// (mit Ton) angezeigt werden.
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
