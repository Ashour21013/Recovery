import SwiftUI

/// Zentrale Typografie des Design-Systems.
///
/// Alle Werte basieren auf semantischen Text-Styles und skalieren daher
/// automatisch mit Dynamic Type (Accessibility). Für prominente Zahlen wird
/// eine gerundete Variante angeboten, die ebenfalls mit der Nutzergröße wächst.
enum AppFont {
    static let largeTitle = Font.largeTitle.bold()
    static let title = Font.title.bold()
    static let title2 = Font.title2.weight(.semibold)
    static let headline = Font.headline
    static let body = Font.body
    static let subheadline = Font.subheadline
    static let footnote = Font.footnote
    static let caption = Font.caption

    /// Große, abgerundete Zahl (z. B. Streak) – skaliert mit Dynamic Type
    /// relativ zum `largeTitle`-Textstil statt fixer Punktgröße.
    static func roundedNumber(relativeTo style: Font.TextStyle = .largeTitle) -> Font {
        .system(style, design: .rounded).weight(.bold)
    }
}
