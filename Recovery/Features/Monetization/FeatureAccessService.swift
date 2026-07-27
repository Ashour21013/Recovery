import Foundation
import Observation

/// Abstraktion für die Prüfung von Premium-Feature-Zugriffen.
///
/// Views/ViewModels kennen nur dieses Protokoll, nie den konkreten
/// `SubscriptionService` (Dependency Inversion).
@MainActor
protocol FeatureAccessProviding: AnyObject {
    /// Ob das angegebene Feature aktuell freigeschaltet ist.
    func isUnlocked(_ feature: PremiumFeature) -> Bool
    /// Ob der Nutzer generell Premium besitzt.
    var isPremium: Bool { get }
}

/// Entscheidet app-weit, ob ein Premium-Feature freigeschaltet ist.
///
/// Baut auf dem bestehenden `SubscriptionService` (Entitlement-Status) auf.
/// Als `@Observable` reagieren gebundene Views automatisch auf
/// Statusänderungen (z. B. nach einem Kauf).
@Observable
@MainActor
final class FeatureAccessService: FeatureAccessProviding {

    private let subscriptionService: SubscriptionServiceProtocol

    init(subscriptionService: SubscriptionServiceProtocol) {
        self.subscriptionService = subscriptionService
    }

    var isPremium: Bool {
        subscriptionService.entitlementStatus.isPremium
    }

    /// Alle in `PremiumFeature` gelisteten Funktionen sind kostenpflichtig und
    /// damit ausschließlich mit aktivem Premium freigeschaltet.
    func isUnlocked(_ feature: PremiumFeature) -> Bool {
        isPremium
    }
}
