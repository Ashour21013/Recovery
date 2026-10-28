import Foundation

/// Eine positive Affirmation, die der Nutzer im Craving-Modus laut vorliest.
///
/// Als Datenmodell mit statischem, erweiterbarem Katalog gehalten – analog
/// zu `CravingTask`, damit später leicht weitere Affirmationen (z. B. aus
/// Remote-Config) ergänzt werden können.
struct Affirmation: Identifiable, Equatable {
    let id: UUID
    let text: String

    init(id: UUID = UUID(), text: String) {
        self.id = id
        self.text = text
    }
}

extension Affirmation {
    /// Erweiterbarer Katalog möglicher Affirmationen.
    static let catalog: [Affirmation] = [
        Affirmation(text: String(localized: "Ich entscheide mich bewusst für meine Gesundheit.")),
        Affirmation(text: String(localized: "Dieses Verlangen ist vorübergehend – ich bleibe stark.")),
        Affirmation(text: String(localized: "Ich bin stolz auf jeden Tag, den ich durchhalte.")),
        Affirmation(text: String(localized: "Ich habe die Kontrolle über meine Entscheidungen.")),
        Affirmation(text: String(localized: "Jeder Moment des Widerstands macht mich freier."))
    ]

    /// Wählt zufällig eine Affirmation aus dem Katalog.
    static func random() -> Affirmation {
        catalog.randomElement() ?? catalog[0]
    }
}
