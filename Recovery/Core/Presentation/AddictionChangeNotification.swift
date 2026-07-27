import Foundation

/// App-weite Benachrichtigungen rund um die aktive Sucht (Multi-Addiction).
///
/// Da jeder Tab ein eigenes ViewModel besitzt und beim ersten Erscheinen
/// idempotent lädt, würden Journal/Statistik/Erfolge nach einem Sucht-Wechsel
/// weiterhin die zwischengespeicherten Daten der vorherigen Sucht anzeigen.
/// Über diese Notification werden alle Screens informiert und laden neu.
extension Notification.Name {

    /// Wird gepostet, sobald die aktive Sucht gewechselt, hinzugefügt oder
    /// gelöscht wurde. Empfänger sollten ihre Daten neu laden.
    static let activeAddictionDidChange = Notification.Name("recovery.activeAddictionDidChange")
}

/// Zentraler Helfer zum Auslösen des Sucht-Wechsel-Events.
enum AddictionChangeBroadcaster {

    /// Informiert alle Screens, dass sich die aktive Sucht geändert hat.
    @MainActor
    static func broadcast() {
        NotificationCenter.default.post(name: .activeAddictionDidChange, object: nil)
    }
}
