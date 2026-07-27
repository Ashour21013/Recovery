import Foundation
import StoreKit

/// Aufbereitete Anzeige-Informationen zu einem StoreKit-`Product`.
///
/// Kapselt die Formatierung (Preis, Zeitraum, Testphase), damit die View frei
/// von StoreKit-Formatierungslogik bleibt.
struct ProductDisplayInfo {
    let product: Product
    let kind: SubscriptionProduct

    init?(product: Product) {
        guard let kind = SubscriptionProduct(rawValue: product.id) else { return nil }
        self.product = product
        self.kind = kind
    }

    /// Lokalisierter Preis inkl. Währung (z. B. „3,99 €").
    var price: String { product.displayPrice }

    /// Beschreibung des Abrechnungszeitraums (z. B. „pro Monat", „einmalig").
    var periodText: String {
        guard let subscription = product.subscription else {
            return "einmalig"
        }
        return "pro " + periodName(subscription.subscriptionPeriod)
    }

    /// Ob eine kostenlose Einführungs-Testphase verfügbar ist.
    var hasFreeTrial: Bool {
        guard let offer = product.subscription?.introductoryOffer else { return false }
        return offer.paymentMode == .freeTrial
    }

    /// Menschlicher Text zur Testphase (z. B. „7 Tage kostenlos testen").
    var trialText: String? {
        guard let offer = product.subscription?.introductoryOffer,
              offer.paymentMode == .freeTrial else { return nil }
        let period = offer.period
        let count = offer.periodCount * period.value
        let unit = unitName(period.unit, value: count)
        return "\(count) \(unit) kostenlos testen"
    }

    /// Empfehlungs-Badge-Text (nur beim empfohlenen Produkt).
    var badgeText: String? {
        kind.isRecommended ? "Beliebt" : nil
    }

    // MARK: - Formatierung

    private func periodName(_ period: Product.SubscriptionPeriod) -> String {
        switch period.unit {
        case .day: return period.value == 1 ? "Tag" : "\(period.value) Tage"
        case .week: return period.value == 1 ? "Woche" : "\(period.value) Wochen"
        case .month: return period.value == 1 ? "Monat" : "\(period.value) Monate"
        case .year: return period.value == 1 ? "Jahr" : "\(period.value) Jahre"
        @unknown default: return ""
        }
    }

    private func unitName(_ unit: Product.SubscriptionPeriod.Unit, value: Int) -> String {
        switch unit {
        case .day: return value == 1 ? "Tag" : "Tage"
        case .week: return value == 1 ? "Woche" : "Wochen"
        case .month: return value == 1 ? "Monat" : "Monate"
        case .year: return value == 1 ? "Jahr" : "Jahre"
        @unknown default: return ""
        }
    }
}
