import Foundation

/// Tageszeit einer Erinnerung. Reine Domain-Entität ohne UI-Bezug.
enum ReminderTime: String, CaseIterable, Identifiable, Codable {
    case morning
    case noon
    case evening

    var id: String { rawValue }

    var title: String {
        switch self {
        case .morning: "Morgens"
        case .noon: "Mittags"
        case .evening: "Abends"
        }
    }

    var systemImage: String {
        switch self {
        case .morning: "sunrise.fill"
        case .noon: "sun.max.fill"
        case .evening: "moon.stars.fill"
        }
    }

    /// Standard-Uhrzeit (Stunde des Tages) für die jeweilige Erinnerung.
    var defaultHour: Int {
        switch self {
        case .morning: 8
        case .noon: 12
        case .evening: 20
        }
    }

    /// Stabile Notifikations-Identifier-Basis.
    var identifier: String { "recovery.reminder.\(rawValue)" }
}

/// Konfiguration der aktivierten Erinnerungen. Reine Domain-Entität.
struct ReminderSettings: Equatable, Codable {
    /// Aktivierte Tageszeiten.
    var enabledTimes: Set<ReminderTime>

    init(enabledTimes: Set<ReminderTime> = []) {
        self.enabledTimes = enabledTimes
    }

    func isEnabled(_ time: ReminderTime) -> Bool {
        enabledTimes.contains(time)
    }

    static let `default` = ReminderSettings()
}
