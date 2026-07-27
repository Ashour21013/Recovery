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

/// Standard-Factory: kombiniert je Suchtart die passenden Provider
/// (Geld/Zeit) mit optionalen Gesundheits-Meilensteinen (Composite).
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
        switch habitType {
        case .smoking, .alcohol, .gambling:
            // Reine Geld-(+Mengen-)Süchte.
            return moneyProvider

        case .sugar:
            // Geld (nur bei Eingabe) + Gesundheits-Meilensteine.
            return CompositeSavingsProvider([
                moneyProvider,
                HealthSavingsAdapter(SugarHealthProvider())
            ])

        case .pornography:
            // Zurückgewonnene Zeit + Energie-/Fokus-Meilensteine.
            return CompositeSavingsProvider([
                timeProvider,
                HealthSavingsAdapter(PornographyHealthProvider())
            ])

        case .socialMedia:
            // Zurückgewonnene Zeit + Fokus-/Schlaf-Meilensteine.
            return CompositeSavingsProvider([
                timeProvider,
                HealthSavingsAdapter(SocialMediaHealthProvider())
            ])
        }
    }
}
