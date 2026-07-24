import Foundation

/// Provider für gemischte Inhalte.
///
/// Kombiniert mehrere Provider (Composite Pattern) und wählt pro Aufruf einen
/// davon aus. Dadurch erhält der Nutzer abwechselnd Inhalte aller Quellen.
/// Neue Quellen werden automatisch berücksichtigt, sobald sie hier ergänzt
/// werden (Open/Closed).
struct MixedMotivationProvider: MotivationProvider {

    let source: MotivationSource = .mixed

    private let providers: [MotivationProvider]

    init(providers: [MotivationProvider]) {
        self.providers = providers
    }

    func item(for context: MotivationContext, excluding excludedIds: Set<String>) -> MotivationItem {
        guard !providers.isEmpty else {
            return MotivationItem(id: "mixed.fallback", text: "Bleib stark!", source: nil, origin: .mixed)
        }
        // Kontextabhängige, aber wechselnde Auswahl über den Tagesindex.
        let dayIndex = Calendar.current.ordinality(of: .day, in: .era, for: .now) ?? 0
        let provider = providers[dayIndex % providers.count]
        return provider.item(for: context, excluding: excludedIds)
    }
}
