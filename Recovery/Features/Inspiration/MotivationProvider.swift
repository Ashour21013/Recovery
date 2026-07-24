import Foundation

/// Abstraktion für eine Quelle täglicher Motivation.
///
/// Die Presentation-Schicht (Dashboard) kennt ausschließlich dieses
/// Protokoll – niemals die konkreten Implementierungen (Dependency
/// Inversion). Jede Quelle liefert kontextabhängig ein `MotivationItem`.
protocol MotivationProvider {

    /// Die Quelle, die dieser Provider bedient.
    var source: MotivationSource { get }

    /// Liefert ein passendes Motivations-Element für den Kontext.
    ///
    /// - Parameters:
    ///   - context: Situativer Kontext (z. B. Rückfall, Cravings).
    ///   - excludedIds: Zuletzt gezeigte IDs, die vermieden werden sollen
    ///     (Wiederholungsvermeidung an aufeinanderfolgenden Tagen).
    func item(for context: MotivationContext, excluding excludedIds: Set<String>) -> MotivationItem
}
