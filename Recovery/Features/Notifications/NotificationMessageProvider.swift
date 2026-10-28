import Foundation

/// Liefert motivierende Nachrichten für Benachrichtigungen.
/// Erweiterbarer Katalog – frei von UI und Framework-Abhängigkeiten.
enum NotificationMessageProvider {

    private static let messages: [String] = [
        String(localized: "Ein neuer Tag, eine neue Chance stärker zu werden. 💪"),
        String(localized: "Du hast heute schon so viel geschafft – bleib dran!"),
        String(localized: "Denk an dein Warum. Es ist die Anstrengung wert."),
        String(localized: "Jede Stunde ohne Rückfall ist ein Sieg."),
        String(localized: "Du bist stärker als dein Verlangen."),
        String(localized: "Kleine Schritte, große Veränderung. Weiter so!"),
        String(localized: "Sei stolz auf deinen Fortschritt – du machst das großartig."),
        String(localized: "Atme durch. Du hast die Kontrolle.")
    ]

    /// Deterministische Auswahl (z. B. anhand der Tageszeit-Stunde),
    /// damit dieselbe Erinnerung stabile Inhalte erhält.
    static func message(seed: Int) -> String {
        guard !messages.isEmpty else { return String(localized: "Bleib stark!") }
        let index = ((seed % messages.count) + messages.count) % messages.count
        return messages[index]
    }

    static func random() -> String {
        messages.randomElement() ?? String(localized: "Bleib stark!")
    }
}
