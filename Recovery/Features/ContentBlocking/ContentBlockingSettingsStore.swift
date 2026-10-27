import Foundation

/// Persistenz der Inhaltsschutz-Einstellungen.
protocol ContentBlockingSettingsStore: AnyObject {
    var isEnabled: Bool { get set }
    var customDomains: [String] { get set }
    /// Kodierte `FamilyActivitySelection` (opaque Tokens).
    var selectionData: Data? { get set }
}

/// `UserDefaults`-basierte Umsetzung.
final class UserDefaultsContentBlockingSettingsStore: ContentBlockingSettingsStore {

    private let defaults: UserDefaults
    private enum Key {
        static let isEnabled = "contentBlocking.isEnabled"
        static let customDomains = "contentBlocking.customDomains"
        static let selection = "contentBlocking.selection"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var isEnabled: Bool {
        get { defaults.bool(forKey: Key.isEnabled) }
        set { defaults.set(newValue, forKey: Key.isEnabled) }
    }

    var customDomains: [String] {
        get { defaults.stringArray(forKey: Key.customDomains) ?? [] }
        set { defaults.set(newValue, forKey: Key.customDomains) }
    }

    var selectionData: Data? {
        get { defaults.data(forKey: Key.selection) }
        set { defaults.set(newValue, forKey: Key.selection) }
    }
}
