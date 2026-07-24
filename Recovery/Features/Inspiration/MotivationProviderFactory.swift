import Foundation

/// Erzeugt den passenden `MotivationProvider` zu einer `MotivationSource`.
///
/// Dies ist die einzige Stelle, die alle konkreten Provider kennt. Das
/// Dashboard erhält ausschließlich die Protokoll-Abstraktion (Dependency
/// Inversion). Neue Quellen werden nur hier verdrahtet (Open/Closed).
struct MotivationProviderFactory {

    /// Alle „echten" (nicht-gemischten) Provider.
    private let baseProviders: [MotivationProvider]

    init() {
        self.baseProviders = [
            QuotesMotivationProvider(),
            ScienceMotivationProvider(),
            BibleMotivationProvider()
        ]
    }

    /// Liefert den Provider für die gewählte Quelle.
    func provider(for source: MotivationSource) -> MotivationProvider {
        switch source {
        case .quotes:
            return QuotesMotivationProvider()
        case .science:
            return ScienceMotivationProvider()
        case .bible:
            return BibleMotivationProvider()
        case .mixed:
            return MixedMotivationProvider(providers: baseProviders)
        }
    }
}
