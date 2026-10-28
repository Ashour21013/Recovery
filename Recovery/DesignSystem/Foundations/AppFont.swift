import SwiftUI

/// Zentrale Typografie des Design-Systems.
///
/// Alle Werte basieren auf semantischen Text-Styles und skalieren daher
/// automatisch mit Dynamic Type (Accessibility). Für prominente Zahlen wird
/// eine gerundete Variante angeboten, die ebenfalls mit der Nutzergröße wächst.
enum AppFont {
    // Figma: kräftige Überschriften (Bold/Heavy), ruhiger Fließtext.
    static let largeTitle = Font.largeTitle.weight(.heavy)
    static let title = Font.title.bold()
    static let title2 = Font.title2.bold()
    static let headline = Font.headline.weight(.bold)
    static let body = Font.body
    static let subheadline = Font.subheadline
    static let footnote = Font.footnote
    static let caption = Font.caption
    static let caption2 = Font.caption2
    /// Figma-„Eyebrow“: kleine, fette Großbuchstaben-Zeile.
    static let eyebrow = Font.caption2.weight(.heavy)

    /// Große, abgerundete Zahl (z. B. Streak) – skaliert mit Dynamic Type
    /// relativ zum `largeTitle`-Textstil statt fixer Punktgröße.
    static func roundedNumber(relativeTo style: Font.TextStyle = .largeTitle) -> Font {
        .system(style, design: .rounded).weight(.bold)
    }
}
