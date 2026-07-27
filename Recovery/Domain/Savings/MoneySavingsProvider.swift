import Foundation

/// Provider für finanzielle Süchte (Rauchen, Alkohol, Glücksspiel, Zucker).
///
/// Berechnet gespartes Geld und – falls möglich – die vermiedene Konsummenge.
/// Unterstützt zwei Eingabe-Modelle:
/// 1. Preis pro Packung + Einheiten pro Tag (+ Einheiten pro Packung).
/// 2. Direkte Wochenausgaben (`weeklySpend`).
struct MoneySavingsProvider: SavingsMetricProvider {

    func gains(
        for habitType: HabitType,
        streakDays: Int,
        metrics: AddictionMetrics
    ) -> [RecoveryGain] {
        guard streakDays >= 0 else { return [] }

        var result: [RecoveryGain] = []

        if let saved = moneySaved(streakDays: streakDays, metrics: metrics) {
            result.append(
                RecoveryGain(
                    id: "money.saved",
                    kind: .money,
                    value: saved,
                    unit: "EUR",
                    title: "Gespart",
                    detail: savedDetail(perDay: dailyCost(metrics: metrics) ?? 0),
                    systemImage: "eurosign.circle.fill"
                )
            )
        }

        if let avoided = unitsAvoided(streakDays: streakDays, metrics: metrics), avoided > 0 {
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

    // MARK: - Berechnung

    /// Tägliche Kosten aus den Eingaben (Packungslogik oder Wochenausgabe).
    private func dailyCost(metrics: AddictionMetrics) -> Double? {
        if let price = metrics.unitPrice, let perDay = metrics.unitsPerDay {
            let unitsPerPackage = metrics.unitsPerPackage ?? 1
            guard unitsPerPackage > 0 else { return nil }
            let pricePerUnit = (price as NSDecimalNumber).doubleValue / unitsPerPackage
            return pricePerUnit * perDay
        }
        if let weekly = metrics.weeklySpend {
            return (weekly as NSDecimalNumber).doubleValue / 7.0
        }
        return nil
    }

    private func moneySaved(streakDays: Int, metrics: AddictionMetrics) -> Double? {
        guard let perDay = dailyCost(metrics: metrics) else { return nil }
        return perDay * Double(streakDays)
    }

    private func unitsAvoided(streakDays: Int, metrics: AddictionMetrics) -> Double? {
        guard let perDay = metrics.unitsPerDay else { return nil }
        return perDay * Double(streakDays)
    }

    private func savedDetail(perDay: Double) -> String {
        let monthly = Decimal(perDay * 30)
        return "Etwa \(monthly.formatted(.currency(code: "EUR"))) pro Monat"
    }
}
