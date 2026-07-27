import Foundation
import StoreKit

/// Abstraktion des In-App-Purchase-Systems (StoreKit 2).
///
/// Die Presentation-Schicht (Paywall) kennt ausschließlich dieses Protokoll,
/// niemals die konkrete StoreKit-Implementierung (Dependency Inversion). So
/// bleibt das ViewModel testbar und die Kaufl­ogik austauschbar.
@MainActor
protocol SubscriptionServiceProtocol: AnyObject {

    /// Aktueller, app-weiter Berechtigungsstatus.
    var entitlementStatus: EntitlementStatus { get }

    /// Geladene, verkaufbare Produkte (bereits sortiert).
    var products: [Product] { get }

    /// Ob gerade eine Aktion (Laden/Kauf/Restore) läuft.
    var isLoading: Bool { get }

    /// Lädt die Produkte aus dem Store.
    func loadProducts() async

    /// Führt einen Kauf für das angegebene Produkt durch.
    @discardableResult
    func purchase(_ product: Product) async throws -> PurchaseResult

    /// Stellt frühere Käufe wieder her.
    func restore() async

    /// Aktualisiert den Entitlement-Status aus den aktuellen Berechtigungen.
    func refreshEntitlements() async
}
