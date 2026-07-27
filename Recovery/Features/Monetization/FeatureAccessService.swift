import Foundation
import Observation

/// Drei-Zustands-Ergebnis einer Feature-Zugriffsprüfung.
///
/// Verhindert das kurze Aufblitzen der gesperrten Ansicht beim App-Start,
/// solange der echte Entitlement-Status noch nicht vorliegt.
enum FeatureAccessState: Equatable {
    /// Der Entitlement-Status wird noch geladen – neutraler Ladezustand zeigen.
    case loading
    /// Feature ist freigeschaltet.
    case unlocked
    /// Feature ist gesperrt (kein Premium).
    case locked
}

/// Abstraktion für die Prüfung von Premium-Feature-Zugriffen.
///
/// Views/ViewModels kennen nur dieses Protokoll, nie den konkreten
/// `SubscriptionService` (Dependency Inversion).
@MainActor
protocol FeatureAccessProviding: AnyObject {
    /// Ob das angegebene Feature aktuell freigeschaltet ist.
    func isUnlocked(_ feature: PremiumFeature) -> Bool
    /// Drei-Zustands-Prüfung inkl. Ladezustand (bevorzugt für UI-Gating).
    func access(_ feature: PremiumFeature) -> FeatureAccessState
    /// Ob der Nutzer generell Premium besitzt.
    var isPremium: Bool { get }
    /// Ob der Entitlement-Status bereits ermittelt wurde.
    var isResolved: Bool { get }
    /// Lädt den initialen Entitlement-Status (früh beim App-Start aufrufen).
    func refresh() async
}

/// Entscheidet app-weit, ob ein Premium-Feature freigeschaltet ist.
///
/// Baut auf dem bestehenden `SubscriptionService` (Entitlement-Status) auf.
/// Als `@Observable` reagieren gebundene Views automatisch auf
/// Statusänderungen (z. B. nach einem Kauf oder sobald der initiale Status
/// vorliegt).
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

    /// `true`, sobald der Status nicht mehr `.unknown` ist.
    var isResolved: Bool {
        subscriptionService.entitlementStatus != .unknown
    }

    /// Alle in `PremiumFeature` gelisteten Funktionen sind kostenpflichtig und
    /// damit ausschließlich mit aktivem Premium freigeschaltet.
    func isUnlocked(_ feature: PremiumFeature) -> Bool {
        isPremium
    }

    /// Drei-Zustands-Prüfung: solange der Status lädt, wird `.loading`
    /// zurückgegeben, damit die UI weder Inhalt noch Paywall final zeigt.
    func access(_ feature: PremiumFeature) -> FeatureAccessState {
        guard isResolved else { return .loading }
        return isUnlocked(feature) ? .unlocked : .locked
    }

    /// Ermittelt den initialen Entitlement-Status möglichst früh beim Start.
    func refresh() async {
        await subscriptionService.refreshEntitlements()
    }
}

