import Foundation

/// Provider für Bibelverse.
///
/// Wählt Verse kontextabhängig: Der `MotivationContext` bestimmt die
/// bevorzugten `BibleCategory`-Themen (z. B. Versuchung bei Cravings,
/// Vergebung bei Rückfall). Wiederholungen werden vermieden.
struct BibleMotivationProvider: MotivationProvider {

    let source: MotivationSource = .bible

    func item(for context: MotivationContext, excluding excludedIds: Set<String>) -> MotivationItem {
        let candidates = BibleVerseCatalog.verses(matching: context.preferredBibleCategories)
        let pool = candidates.isEmpty ? BibleVerseCatalog.verses : candidates

        let verse = MotivationPicker.pick(from: pool, id: \.id, excluding: excludedIds)
            ?? pool[0]

        return MotivationItem(
            id: "bible.\(verse.reference)",
            text: verse.text,
            source: verse.reference,
            origin: .bible
        )
    }
}
