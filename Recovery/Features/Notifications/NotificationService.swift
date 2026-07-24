import Foundation

/// Abstraktion für lokale Benachrichtigungen.
///
/// ViewModels kennen nur dieses Protokoll, niemals `UserNotifications`
/// direkt – dadurch bleibt die Presentation-Schicht testbar und das
/// Framework austauschbar (Dependency Inversion).
protocol NotificationService {

    /// Fragt die Berechtigung für lokale Benachrichtigungen an.
    /// Gibt `true` zurück, wenn erlaubt.
    func requestAuthorization() async -> Bool

    /// Aktueller Autorisierungsstatus (erlaubt/abgelehnt).
    func isAuthorized() async -> Bool

    /// Plant die täglichen Erinnerungen gemäß Konfiguration neu.
    /// Bestehende Recovery-Erinnerungen werden zuvor entfernt.
    func scheduleReminders(_ settings: ReminderSettings) async

    /// Entfernt alle geplanten Recovery-Erinnerungen.
    func cancelAllReminders() async
}
