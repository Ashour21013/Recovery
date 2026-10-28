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

    // MARK: - Figma-Palette (Light / Dark)

    static let ink = Color(light: 0x173B39, dark: 0xE9F4F1)
    static let muted = Color(light: 0x6E8581, dark: 0x8CA5A0)
    static let teal = Color(light: 0x177E77, dark: 0x3FB3A6)
    static let deep = Color(hex: 0x0D625D)
    static let mint = Color(light: 0xD9F2EB, dark: 0x1C4842)
    static let line = Color(light: 0xDCE7E3, dark: 0x29433F)
    static let surface = Color(light: 0xFFFFFF, dark: 0x1B312E)
    static let background = Color(light: 0xF5F8F6, dark: 0x102321)
    static let coral = Color(hex: 0xDB806B)
    static let coralSoft = Color(light: 0xFFEDE8, dark: 0x4A3029)
    static let gold = Color(hex: 0xA97C28)
    static let goldSoft = Color(light: 0xFFF3D6, dark: 0x4D411E)
    static let purple = Color(hex: 0x7757A2)
    static let purpleSoft = Color(light: 0xEEE7F6, dark: 0x352A42)
    static let green = Color(hex: 0x31845D)
    static let greenSoft = Color(light: 0xDFF2E8, dark: 0x1C4937)

    static let heroGradient = LinearGradient(
        colors: [Color(hex: 0x208F86), Color(hex: 0x0B5C58)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let quoteGradient = LinearGradient(
        colors: [Color(hex: 0x314F50), Color(hex: 0x1D3536)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
}

/// Eckenradien aus dem Figma-Design.
enum AppRadius {
    static let small: CGFloat = 12
    static let button: CGFloat = 17
    static let card: CGFloat = 22
    static let hero: CGFloat = 26
}

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }

    init(light: UInt32, dark: UInt32) {
        self.init(UIColor { traits in
            UIColor(Color(hex: traits.userInterfaceStyle == .dark ? dark : light))
        })
    }
}
