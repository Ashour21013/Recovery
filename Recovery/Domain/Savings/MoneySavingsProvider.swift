import Foundation

/// Provider für finanzielle Süchte (Rauchen, Alkohol, Glücksspiel, Zucker).
///
/// Berechnet gespartes Geld und – falls möglich – die vermiedene Menge.
/// Das konkrete Verhalten richtet sich nach der Suchtart:
/// - Rauchen: Preis pro Schachtel ÷ Zigaretten/Schachtel × Zigaretten/Tag
///   → Geld gespart + vermiedene Zigaretten.
/// - Alkohol: Wochenausgabe ÷ 7 → Geld, optional Getränke/Woche → vermiedene Getränke.
/// - Glücksspiel: Wocheneinsatz ÷ 7 → "X € nicht verspielt".
/// - Zucker: Wochenausgabe ÷ 7 → Geld (nur bei Eingabe).
struct MoneySavingsProvider: SavingsMetricProvider {

    func gains(
        for habitType: HabitType,
        streakDays: Int,
        metrics: AddictionMetrics
    ) -> [RecoveryGain] {
        guard streakDays >= 0 else { return [] }

        var result: [RecoveryGain] = []

        // 1. Geld gespart / nicht verspielt.
        if let perDay = dailyCost(for: habitType, metrics: metrics) {
            let saved = perDay * Double(streakDays)
            result.append(
                RecoveryGain(
                    id: "money.saved",
                    kind: .money,
                    value: saved,
                    unit: "EUR",
                    title: moneyTitle(for: habitType),
                    detail: monthlyDetail(perDay: perDay),
                    systemImage: "eurosign.circle.fill"
                )
            )
        }

        // 2. Vermiedene Menge (nur wo sinnvoll: Rauchen, Alkohol).
        if let avoided = unitsAvoided(for: habitType, streakDays: streakDays, metrics: metrics),
           avoided > 0 {
            result.append(
                RecoveryGain(
                    id: "money.avoided",
                    kind: .quantity,
                    value: avoided,
                    unit: habitType.consumptionUnitName,
                    title: "Vermieden",
                    detail: "Nicht konsumiert seit dem Start",
                    systemImage: "shield.lefthalf.filled"
                )
            )
        }

        return result
    }

    // MARK: - Tägliche Kosten

    private func dailyCost(for habitType: HabitType, metrics: AddictionMetrics) -> Double? {
        switch habitType {
        case .smoking:
            // Preis pro Schachtel ÷ Zigaretten pro Schachtel × Zigaretten pro Tag.
            guard let price = metrics.unitPrice, let perDay = metrics.unitsPerDay else { return nil }
            let perPackage = metrics.unitsPerPackage ?? 20
            guard perPackage > 0 else { return nil }
            let pricePerCigarette = (price as NSDecimalNumber).doubleValue / perPackage
            return pricePerCigarette * perDay
        default:
            // Alkohol/Glücksspiel/Zucker: Wochenausgabe ÷ 7.
            guard let weekly = metrics.weeklySpend else { return nil }
            return (weekly as NSDecimalNumber).doubleValue / 7.0
        }
    }

    // MARK: - Vermiedene Menge

    private func unitsAvoided(
        for habitType: HabitType,
        streakDays: Int,
        metrics: AddictionMetrics
    ) -> Double? {
        switch habitType {
        case .smoking:
            guard let perDay = metrics.unitsPerDay else { return nil }
            return perDay * Double(streakDays)
        case .alcohol:
            guard let perWeek = metrics.drinksPerWeek else { return nil }
            return (perWeek / 7.0) * Double(streakDays)
        default:
            // Glücksspiel & Zucker: keine Mengenangabe.
            return nil
        }
    }

    // MARK: - Texte

    private func moneyTitle(for habitType: HabitType) -> String {
        habitType == .gambling ? "Nicht verspielt" : "Gespart"
    }

    private func monthlyDetail(perDay: Double) -> String {
        let monthly = Decimal(perDay * 30)
        return "Etwa \(monthly.formatted(.currency(code: "EUR"))) pro Monat"
    }
}
