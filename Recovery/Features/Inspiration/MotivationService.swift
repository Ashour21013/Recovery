import Foundation

/// Fassade für das Inspiration-System.
///
/// Wählt anhand der gespeicherten `MotivationSource` den passenden Provider
/// (über die Factory) und liefert unter Vermeidung von Wiederholungen ein
/// `MotivationItem`. Das Dashboard kennt nur diese Abstraktion, niemals die
/// konkreten Provider (Dependency Inversion / Clean Architecture).
protocol MotivationService {
    /// Liefert die tägliche Motivation für Quelle und Kontext.
    func dailyMotivation(source: MotivationSource, context: MotivationContext) -> MotivationItem
}

struct DefaultMotivationService: MotivationService {

    private let factory: MotivationProviderFactory
    private let history: MotivationHistoryStore

    init(
        factory: MotivationProviderFactory = MotivationProviderFactory(),
        history: MotivationHistoryStore
    ) {
        self.factory = factory
        self.history = history
    }

    func dailyMotivation(source: MotivationSource, context: MotivationContext) -> MotivationItem {
        let provider = factory.provider(for: source)
        let excluded = Set(history.recentIds())
        let item = provider.item(for: context, excluding: excluded)
        history.record(item.id)
        return item
    }
}
