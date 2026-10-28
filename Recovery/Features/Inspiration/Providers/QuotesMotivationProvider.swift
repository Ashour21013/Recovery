import Foundation

/// Provider für kurze Motivationszitate.
///
/// Kapselt einen erweiterbaren Katalog. Frei von UI- und Persistenzdetails.
struct QuotesMotivationProvider: MotivationProvider {

    let source: MotivationSource = .quotes

    private let quotes: [(text: String, author: String?)] = [
        (String(localized: "Jeder Tag ohne Rückfall ist ein Sieg über dich selbst."), nil),
        (String(localized: "Du bist stärker als deine Gewohnheit."), nil),
        (String(localized: "Kleine Schritte jeden Tag führen zu großen Veränderungen."), nil),
        (String(localized: "Der beste Zeitpunkt anzufangen war gestern. Der zweitbeste ist jetzt."), nil),
        (String(localized: "Stolz auf jeden Tag, den du durchgehalten hast."), nil),
        (String(localized: "Fortschritt ist Fortschritt, egal wie klein."), nil),
        (String(localized: "Fall siebenmal hin, steh achtmal auf."), String(localized: "Japanisches Sprichwort")),
        (String(localized: "Disziplin ist die Brücke zwischen Zielen und Erfolg."), "Jim Rohn"),
        (String(localized: "Der einzige Weg hinaus führt hindurch."), nil),
        (String(localized: "Deine Zukunft wird von dem bestimmt, was du heute tust."), nil)
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
