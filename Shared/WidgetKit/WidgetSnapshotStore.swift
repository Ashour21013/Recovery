import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

/// Liest und schreibt die `WidgetSnapshot` in den geteilten App-Group-Speicher.
///
/// Die Haupt-App schreibt (`save`), das Widget liest (`load`). Reiner
/// Datenzugriff ohne Business-Logik – als Baustein in beiden Targets nutzbar.
struct WidgetSnapshotStore {

    private let defaults: UserDefaults?
    private let key = "recovery.widget.snapshot"

    init(defaults: UserDefaults? = AppGroup.sharedDefaults) {
        self.defaults = defaults
    }

    /// Schreibt den aktuellen Snapshot und fordert eine Widget-Aktualisierung an.
    func save(_ snapshot: WidgetSnapshot) {
        guard let defaults else { return }
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: key)
        reloadWidgets()
    }

    /// Liest den zuletzt gespeicherten Snapshot (nil, wenn keiner vorliegt).
    func load() -> WidgetSnapshot? {
        guard let defaults, let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
    }

    /// Aktualisiert nur den Premium-Status im vorhandenen Snapshot.
    ///
    /// Nützlich, wenn sich das Entitlement ändert (Kauf/Restore/Update),
    /// ohne dass ein vollständiger Neuaufbau aus dem Profil nötig ist.
    /// Existiert noch kein Snapshot, passiert nichts (der volle Aufbau
    /// erfolgt dann beim nächsten App-/Dashboard-Start).
    func updatePremium(_ isPremium: Bool) {
        guard let current = load(), current.isPremium != isPremium else { return }
        let updated = current.withPremium(isPremium)
        save(updated)
    }

    private func reloadWidgets() {
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }
}
