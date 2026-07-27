import Foundation

/// Liefert den zu einer Suchtart passenden `SavingsMetricProvider`.
///
/// Kapselt die Zuordnung Suchtart → Provider an einer Stelle. Neue Süchte
/// oder Metrik-Kategorien lassen sich hier zentral ergänzen, ohne aufrufende
/// Schichten zu ändern (Open/Closed-Prinzip, Dependency Injection).
protocol SavingsMetricProviderFactory {
    /// Liefert den passenden Provider für die angegebene Suchtart.
    func provider(for habitType: HabitType) -> SavingsMetricProvider
}

/// Standard-Factory basierend auf `HabitType.metricCategory`.
struct DefaultSavingsMetricProviderFactory: SavingsMetricProviderFactory {

    private let moneyProvider: SavingsMetricProvider
    private let timeProvider: SavingsMetricProvider

    init(
        moneyProvider: SavingsMetricProvider = MoneySavingsProvider(),
        timeProvider: SavingsMetricProvider = TimeSavingsProvider()
    ) {
        self.moneyProvider = moneyProvider
        self.timeProvider = timeProvider
    }

    func provider(for habitType: HabitType) -> SavingsMetricProvider {
        switch habitType.metricCategory {
        case .money: return moneyProvider
        case .time: return timeProvider
        }
    }
}
