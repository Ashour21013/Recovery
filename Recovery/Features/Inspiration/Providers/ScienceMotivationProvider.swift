import Foundation

/// Provider für wissenschaftlich fundierte Motivation.
///
/// Liefert kurze, auf Forschung basierende Hinweise (Neuroplastizität,
/// Gewohnheitsbildung usw.). Erweiterbarer Katalog, frei von UI/Persistenz.
struct ScienceMotivationProvider: MotivationProvider {

    let source: MotivationSource = .science

    private let facts: [(text: String, source: String)] = [
        ("Cravings dauern meist nur wenige Minuten. Wenn du die Welle überstehst, wird sie messbar schwächer.",
         "Urge Surfing, Marlatt"),
        ("Dein Gehirn bildet neue Verbindungen – Neuroplastizität macht jede Abstinenz einfacher.",
         "Neurowissenschaft"),
        ("Es dauert im Schnitt rund 66 Tage, bis eine neue Gewohnheit automatisch wird.",
         "Lally et al., 2010"),
        ("Schon 10 Minuten Bewegung senken nachweislich das Verlangen.",
         "Verhaltensforschung"),
        ("Wer sein Warum aufschreibt, hält Ziele deutlich häufiger durch.",
         "Zielsetzungsforschung"),
        ("Dopamin-Systeme erholen sich mit der Zeit – Freude an kleinen Dingen kehrt zurück.",
         "Neurowissenschaft"),
        ("Selbstmitgefühl nach einem Rückschlag erhöht die Wahrscheinlichkeit, dranzubleiben.",
         "Neff, Selbstmitgefühlsforschung"),
        ("Ausreichend Schlaf stärkt die Selbstkontrolle im präfrontalen Cortex.",
         "Schlafforschung")
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
