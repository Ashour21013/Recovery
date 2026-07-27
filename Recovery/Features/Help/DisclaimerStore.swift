import Foundation

/// Speichert, ob der Nutzer den rechtlichen Disclaimer bestätigt hat.
///
/// Abstraktion, damit die Persistenz (aktuell `UserDefaults`) austauschbar
/// bleibt und in Tests gemockt werden kann.
protocol DisclaimerStore {
    /// `true`, sobald der Disclaimer einmal akzeptiert wurde.
    var hasAcceptedDisclaimer: Bool { get }
    /// Markiert den Disclaimer als akzeptiert (persistiert).
    func acceptDisclaimer()
}

/// `UserDefaults`-basierte Implementierung des `DisclaimerStore`.
struct UserDefaultsDisclaimerStore: DisclaimerStore {
    private let defaults: UserDefaults
    private let key = "recovery.hasAcceptedDisclaimer"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var hasAcceptedDisclaimer: Bool {
        defaults.bool(forKey: key)
    }

    func acceptDisclaimer() {
        defaults.set(true, forKey: key)
    }
}
