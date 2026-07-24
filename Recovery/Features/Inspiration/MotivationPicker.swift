import Foundation

/// Kleiner Hilfs-Baustein zur Auswahl eines Elements unter Vermeidung
/// zuletzt gezeigter Einträge. Zustandslos und dadurch leicht testbar.
enum MotivationPicker {

    /// Wählt ein Element aus `candidates`, das nach Möglichkeit nicht in
    /// `excludedIds` enthalten ist. Fällt zurück, wenn alle ausgeschlossen
    /// sind. Leere Eingaben liefern `nil`.
    static func pick<T>(
        from candidates: [T],
        id: (T) -> String,
        excluding excludedIds: Set<String>,
        randomSource: () -> Double = { Double.random(in: 0..<1) }
    ) -> T? {
        guard !candidates.isEmpty else { return nil }

        let fresh = candidates.filter { !excludedIds.contains(id($0)) }
        let pool = fresh.isEmpty ? candidates : fresh

        let index = Int(randomSource() * Double(pool.count)) % pool.count
        return pool[index]
    }
}
