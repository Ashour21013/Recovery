import Foundation

/// Provider für kurze Motivationszitate.
///
/// Kapselt einen erweiterbaren Katalog. Frei von UI- und Persistenzdetails.
struct QuotesMotivationProvider: MotivationProvider {

    let source: MotivationSource = .quotes

    private let quotes: [(text: String, author: String?)] = [
        ("Jeder Tag ohne Rückfall ist ein Sieg über dich selbst.", nil),
        ("Du bist stärker als deine Gewohnheit.", nil),
        ("Kleine Schritte jeden Tag führen zu großen Veränderungen.", nil),
        ("Der beste Zeitpunkt anzufangen war gestern. Der zweitbeste ist jetzt.", nil),
        ("Stolz auf jeden Tag, den du durchgehalten hast.", nil),
        ("Fortschritt ist Fortschritt, egal wie klein.", nil),
        ("Fall siebenmal hin, steh achtmal auf.", "Japanisches Sprichwort"),
        ("Disziplin ist die Brücke zwischen Zielen und Erfolg.", "Jim Rohn"),
        ("Der einzige Weg hinaus führt hindurch.", nil),
        ("Deine Zukunft wird von dem bestimmt, was du heute tust.", nil)
    ]

    func item(for context: MotivationContext, excluding excludedIds: Set<String>) -> MotivationItem {
        let items = quotes.map {
            MotivationItem(id: idFor($0.text), text: $0.text, source: $0.author, origin: .quotes)
        }
        return MotivationPicker.pick(from: items, id: \.id, excluding: excludedIds)
            ?? items[0]
    }

    private func idFor(_ text: String) -> String { "quote.\(text.hashValue)" }
}
