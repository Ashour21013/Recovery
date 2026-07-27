import SwiftUI

/// Zentrale Farbpalette des Design-Systems.
///
/// Es werden ausschließlich semantische System-Farben verwendet, damit die App
/// automatisch korrekt im Light- und Dark-Mode sowie bei erhöhtem Kontrast
/// dargestellt wird.
enum AppColor {
    /// Primäre Akzentfarbe (aus dem Asset-Katalog).
    static let accent = Color.accentColor

    /// Karten-/Sekundärhintergrund (passt sich dem Farbschema an).
    static let cardBackground = Color(.secondarySystemBackground)

    /// Standard-Rahmen-/Trennlinienfarbe.
    static let separator = Color(.separator)

    /// Positive Bestätigung (z. B. erreichtes Ziel).
    static let success = Color.green

    /// Warn-/Trigger-Hervorhebung.
    static let warning = Color.orange
}
