import Foundation
import UserNotifications

/// Geteilte Logik des Recovery-Gartens (App + Widget): Stufen, Gieß-Status
/// und die Erinnerung „Deine Pflanze wartet auf Wasser“.
enum PlantGarden {

    static let maxStage = 5
    static let thresholds = [1, 7, 14, 30, 90]

    static let lastWateredKey = "plant.lastWateredDay"
    static let waterCountKey = "plant.waterCount"
    static let reminderEnabledKey = "plant.reminderEnabled"
    static let reminderIdentifier = "recovery.plant.water"
    static let reminderHour = 19

    static var defaults: UserDefaults { AppGroup.sharedDefaults ?? .standard }

    static func stage(for days: Int) -> Int {
        thresholds.filter { days >= $0 }.count
    }

    static func todayKey(_ date: Date = .now) -> String {
        let c = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return "\(c.year ?? 0)-\(c.month ?? 0)-\(c.day ?? 0)"
    }

    static var isWateredToday: Bool {
        defaults.string(forKey: lastWateredKey) == todayKey()
    }

    static var isReminderEnabled: Bool {
        defaults.object(forKey: reminderEnabledKey) as? Bool ?? true
    }

    @discardableResult
    static func markWatered() -> Bool {
        guard !isWateredToday else { return false }
        defaults.set(todayKey(), forKey: lastWateredKey)
        defaults.set(defaults.integer(forKey: waterCountKey) + 1, forKey: waterCountKey)
        return true
    }

    /// Plant die einmalige Erinnerung neu: heute um 19 Uhr, falls noch nicht
    /// gegossen und die Uhrzeit nicht vorbei ist – sonst morgen. Fragt nie selbst
    /// nach der Berechtigung.
    static func refreshReminder(now: Date = .now) async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])
        guard isReminderEnabled else { return }

        let status = await center.notificationSettings().authorizationStatus
        guard status == .authorized || status == .provisional || status == .ephemeral else { return }

        let calendar = Calendar.current
        var target = calendar.date(bySettingHour: reminderHour, minute: 0, second: 0, of: now) ?? now
        if isWateredToday || target <= now {
            target = calendar.date(byAdding: .day, value: 1, to: target) ?? target
        }

        let content = UNMutableNotificationContent()
        content.title = String(localized: "Deine Pflanze wartet auf Wasser 💧")
        content.body = String(localized: "Gieße sie kurz – so bleibt dein Recovery-Garten lebendig.")
        content.sound = .default

        let parts = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: target)
        let trigger = UNCalendarNotificationTrigger(dateMatching: parts, repeats: false)
        try? await center.add(UNNotificationRequest(identifier: reminderIdentifier, content: content, trigger: trigger))
    }
}
