import Foundation

/// Sammelt möglichst viele eindeutige Motivations-Elemente eines Providers,
/// ohne die Kataloge zu duplizieren.
///
/// Nutzt die vorhandene `item(for:excluding:)`-API und schließt bereits
/// gesammelte IDs sukzessive aus, bis keine neuen Elemente mehr geliefert
/// werden. So bleiben die Sprüche konsistent mit der App (Single Source of
/// Truth: die Provider-Kataloge).
extension MotivationProvider {

    /// Liefert bis zu `limit` eindeutige Elemente für den Kontext.
    func collectItems(
        for context: MotivationContext = .daily,
        limit: Int = 40
    ) -> [MotivationItem] {
        var collected: [MotivationItem] = []
        var seen = Set<String>()

        // Bounded Loop: bricht ab, sobald keine neuen IDs mehr auftauchen.
        var misses = 0
        while collected.count < limit && misses < 3 {
            let item = item(for: context, excluding: seen)
            if seen.insert(item.id).inserted {
                collected.append(item)
                misses = 0
            } else {
                misses += 1
            }
        }
        return collected
    }
}
