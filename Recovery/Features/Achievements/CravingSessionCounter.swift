import Foundation

/// Zählt abgeschlossene Craving-Sessions (gerätelokal).
///
/// Bewusst über ein Protokoll abstrahiert und via `UserDefaults` umgesetzt –
/// es handelt sich um einen einfachen Zähler ohne Relationsbedarf.
protocol CravingSessionCounter {
    var completedCount: Int { get }
    func incrementCompleted()
}

final class UserDefaultsCravingSessionCounter: CravingSessionCounter {

    private let defaults: UserDefaults
    private let key = "recovery.completedCravingSessions"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var completedCount: Int {
        defaults.integer(forKey: key)
    }

    func incrementCompleted() {
        defaults.set(completedCount + 1, forKey: key)
    }
}
