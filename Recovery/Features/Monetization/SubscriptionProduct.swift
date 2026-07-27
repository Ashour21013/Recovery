import Foundation

/// Alle In-App-Produkte der App.
///
/// Zentrale, typsichere Definition der Produkt-IDs. Diese IDs müssen exakt
/// mit den Einträgen in der `.storekit`-Datei bzw. in App Store Connect
/// übereinstimmen.
enum SubscriptionProduct: String, CaseIterable, Identifiable {
    case monthly = "recovery.monthly"
    case yearly = "recovery.yearly"
    case lifetime = "recovery.lifetime"

    var id: String { rawValue }

    /// Alle Produkt-IDs als `Set` (für StoreKit-Abfragen).
    static var allProductIDs: Set<String> {
        Set(allCases.map(\.rawValue))
    }

    /// Kurzer Anzeigename.
    var displayName: String {
        switch self {
        case .monthly: return "Monatlich"
        case .yearly: return "Jährlich"
        case .lifetime: return "Lifetime"
        }
    }

    /// Ob dieses Produkt als Empfehlung hervorgehoben werden soll.
    var isRecommended: Bool {
        self == .yearly
    }
}
