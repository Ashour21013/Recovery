import Foundation

/// Liefert motivierende Nachrichten für Benachrichtigungen.
/// Erweiterbarer Katalog – frei von UI und Framework-Abhängigkeiten.
enum NotificationMessageProvider {

    private static let messages: [String] = [
        "Ein neuer Tag, eine neue Chance stärker zu werden. 💪",
        "Du hast heute schon so viel geschafft – bleib dran!",
        "Denk an dein Warum. Es ist die Anstrengung wert.",
        "Jede Stunde ohne Rückfall ist ein Sieg.",
        "Du bist stärker als dein Verlangen.",
        "Kleine Schritte, große Veränderung. Weiter so!",
        "Sei stolz auf deinen Fortschritt – du machst das großartig.",
        "Atme durch. Du hast die Kontrolle."
    ]

    /// Deterministische Auswahl (z. B. anhand der Tageszeit-Stunde),
    /// damit dieselbe Erinnerung stabile Inhalte erhält.
    static func message(seed: Int) -> String {
        guard !messages.isEmpty else { return "Bleib stark!" }
        let index = ((seed % messages.count) + messages.count) % messages.count
        return messages[index]
    }

    static func random() -> String {
        messages.randomElement() ?? "Bleib stark!"
    }
}
