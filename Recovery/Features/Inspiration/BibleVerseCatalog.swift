import Foundation

/// Erweiterbarer Katalog von Bibelversen mit thematischer Zuordnung.
/// Reine Datenquelle ohne UI/Persistenz.
enum BibleVerseCatalog {

    static let verses: [BibleVerse] = [
        // Hoffnung
        BibleVerse(
            reference: "Jeremia 29,11",
            text: "Denn ich weiß, was ich für Gedanken über euch habe: Gedanken des Friedens und nicht des Leides, dass ich euch gebe Zukunft und Hoffnung.",
            categories: [.hope]
        ),
        BibleVerse(
            reference: "Römer 15,13",
            text: "Der Gott der Hoffnung aber erfülle euch mit aller Freude und Frieden im Glauben.",
            categories: [.hope, .strength]
        ),
        BibleVerse(
            reference: "Klagelieder 3,22-23",
            text: "Die Güte des HERRN ist's, dass wir nicht gar aus sind; seine Barmherzigkeit hat noch kein Ende, sondern sie ist alle Morgen neu.",
            categories: [.hope, .forgiveness]
        ),

        // Versuchung
        BibleVerse(
            reference: "1. Korinther 10,13",
            text: "Gott ist treu, der euch nicht versuchen lässt über eure Kraft, sondern macht, dass die Versuchung so ein Ende nimmt, dass ihr's ertragen könnt.",
            categories: [.temptation, .strength]
        ),
        BibleVerse(
            reference: "Jakobus 4,7",
            text: "So seid nun Gott untertänig. Widersteht dem Teufel, so flieht er von euch.",
            categories: [.temptation]
        ),
        BibleVerse(
            reference: "Matthäus 26,41",
            text: "Wachet und betet, dass ihr nicht in Anfechtung fallt! Der Geist ist willig; aber das Fleisch ist schwach.",
            categories: [.temptation, .perseverance]
        ),

        // Stärke
        BibleVerse(
            reference: "Philipper 4,13",
            text: "Ich vermag alles durch den, der mich mächtig macht, Christus.",
            categories: [.strength, .perseverance]
        ),
        BibleVerse(
            reference: "Jesaja 41,10",
            text: "Fürchte dich nicht, ich bin mit dir; weiche nicht, denn ich bin dein Gott. Ich stärke dich, ich helfe dir auch.",
            categories: [.strength, .hope]
        ),
        BibleVerse(
            reference: "Psalm 46,2",
            text: "Gott ist unsre Zuversicht und Stärke, eine Hilfe in den großen Nöten, die uns getroffen haben.",
            categories: [.strength, .hope]
        ),

        // Ausdauer
        BibleVerse(
            reference: "Galater 6,9",
            text: "Lasst uns aber Gutes tun und nicht müde werden; denn zu seiner Zeit werden wir auch ernten, wenn wir nicht nachlassen.",
            categories: [.perseverance]
        ),
        BibleVerse(
            reference: "Hebräer 12,1",
            text: "Lasst uns laufen mit Geduld in dem Kampf, der uns bestimmt ist.",
            categories: [.perseverance, .strength]
        ),
        BibleVerse(
            reference: "Jakobus 1,12",
            text: "Selig ist der Mann, der die Anfechtung erduldet; denn nachdem er bewährt ist, wird er die Krone des Lebens empfangen.",
            categories: [.perseverance, .hope]
        ),

        // Vergebung
        BibleVerse(
            reference: "1. Johannes 1,9",
            text: "Wenn wir aber unsre Sünden bekennen, so ist er treu und gerecht, dass er uns die Sünden vergibt und reinigt uns von aller Ungerechtigkeit.",
            categories: [.forgiveness, .hope]
        ),
        BibleVerse(
            reference: "Psalm 103,12",
            text: "So fern der Morgen ist vom Abend, lässt er unsre Übertretungen von uns sein.",
            categories: [.forgiveness]
        ),
        BibleVerse(
            reference: "Sprüche 24,16",
            text: "Denn ein Gerechter fällt siebenmal und steht wieder auf.",
            categories: [.forgiveness, .perseverance, .hope]
        )
    ]

    /// Liefert Verse, die zu mindestens einer der Kategorien passen –
    /// nach Priorität der Kategorien-Reihenfolge sortiert.
    static func verses(matching categories: [BibleCategory]) -> [BibleVerse] {
        guard !categories.isEmpty else { return verses }
        let priority = Dictionary(uniqueKeysWithValues: categories.enumerated().map { ($1, $0) })
        return verses
            .compactMap { verse -> (BibleVerse, Int)? in
                let ranks = verse.categories.compactMap { priority[$0] }
                guard let best = ranks.min() else { return nil }
                return (verse, best)
            }
            .sorted { $0.1 < $1.1 }
            .map(\.0)
    }
}
