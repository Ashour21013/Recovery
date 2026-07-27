import Foundation

/// App-weiter Premium-Berechtigungsstatus (Entitlement).
///
/// Wird aus den aktiven StoreKit-Transaktionen abgeleitet und app-weit über
/// den `SubscriptionService` bereitgestellt.
enum EntitlementStatus: Equatable {
    /// Noch nicht geprüft.
    case unknown
    /// Kein aktives Premium.
    case notSubscribed
    /// Aktives Premium (Abo oder Lifetime).
    case subscribed(SubscriptionProduct)

    /// Ob der Nutzer aktuell Premium-Zugriff hat.
    var isPremium: Bool {
        if case .subscribed = self { return true }
        return false
    }
}
