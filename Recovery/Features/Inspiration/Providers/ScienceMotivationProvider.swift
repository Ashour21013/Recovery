import Foundation

/// Provider für wissenschaftlich fundierte Motivation.
///
/// Liefert kurze, auf Forschung basierende Hinweise (Neuroplastizität,
/// Gewohnheitsbildung usw.). Erweiterbarer Katalog, frei von UI/Persistenz.
struct ScienceMotivationProvider: MotivationProvider {

    let source: MotivationSource = .science

    private let facts: [(text: String, source: String)] = [
        (String(localized: "Cravings dauern meist nur wenige Minuten. Wenn du die Welle überstehst, wird sie messbar schwächer."),
         String(localized: "Urge Surfing, Marlatt")),
        (String(localized: "Dein Gehirn bildet neue Verbindungen – Neuroplastizität macht jede Abstinenz einfacher."),
         String(localized: "Neurowissenschaft")),
        (String(localized: "Es dauert im Schnitt rund 66 Tage, bis eine neue Gewohnheit automatisch wird."),
         "Lally et al., 2010"),
        (String(localized: "Schon 10 Minuten Bewegung senken nachweislich das Verlangen."),
         String(localized: "Verhaltensforschung")),
        (String(localized: "Wer sein Warum aufschreibt, hält Ziele deutlich häufiger durch."),
         String(localized: "Zielsetzungsforschung")),
        (String(localized: "Dopamin-Systeme erholen sich mit der Zeit – Freude an kleinen Dingen kehrt zurück."),
         String(localized: "Neurowissenschaft")),
        (String(localized: "Selbstmitgefühl nach einem Rückschlag erhöht die Wahrscheinlichkeit, dranzubleiben."),
         String(localized: "Neff, Selbstmitgefühlsforschung")),
        (String(localized: "Ausreichend Schlaf stärkt die Selbstkontrolle im präfrontalen Cortex."),
         String(localized: "Schlafforschung"))
    ]

    func item(for context: MotivationContext, excluding excludedIds: Set<String>) -> MotivationItem {
        let items = facts.map {
            MotivationItem(id: idFor($0.text), text: $0.text, source: $0.source, origin: .science)
        }
        return MotivationPicker.pick(from: items, id: \.id, excluding: excludedIds)
            ?? items[0]
    }

    private func idFor(_ text: String) -> String { "science.\(text.hashValue)" }
}
