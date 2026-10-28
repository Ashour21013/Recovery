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
            return String(localized: "einmalig")
        }
        return periodName(subscription.subscriptionPeriod)
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
        return trialDescription(period.unit, count: count)
    }

    /// Empfehlungs-Badge-Text (nur beim empfohlenen Produkt).
    var badgeText: String? {
        kind.isRecommended ? String(localized: "Beliebt") : nil
    }

    // MARK: - Formatierung

    private func periodName(_ period: Product.SubscriptionPeriod) -> String {
        let value = period.value
        switch period.unit {
        case .day:
            return value == 1 ? String(localized: "pro Tag") : String(localized: "pro \(value) Tage")
        case .week:
            return value == 1 ? String(localized: "pro Woche") : String(localized: "pro \(value) Wochen")
        case .month:
            return value == 1 ? String(localized: "pro Monat") : String(localized: "pro \(value) Monate")
        case .year:
            return value == 1 ? String(localized: "pro Jahr") : String(localized: "pro \(value) Jahre")
        @unknown default: return ""
        }
    }

    private func trialDescription(_ unit: Product.SubscriptionPeriod.Unit, count: Int) -> String {
        switch unit {
        case .day:
            return count == 1 ? String(localized: "1 Tag kostenlos testen") : String(localized: "\(count) Tage kostenlos testen")
        case .week:
            return count == 1 ? String(localized: "1 Woche kostenlos testen") : String(localized: "\(count) Wochen kostenlos testen")
        case .month:
            return count == 1 ? String(localized: "1 Monat kostenlos testen") : String(localized: "\(count) Monate kostenlos testen")
        case .year:
            return count == 1 ? String(localized: "1 Jahr kostenlos testen") : String(localized: "\(count) Jahre kostenlos testen")
        @unknown default: return ""
        }
    }
}
