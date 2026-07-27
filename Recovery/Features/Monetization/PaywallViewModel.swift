import Foundation
import StoreKit
import Observation

/// ViewModel der Paywall (MVVM).
///
/// Vermittelt zwischen `PaywallView` und dem `SubscriptionServiceProtocol`.
/// Enthält Präsentationslogik (Auswahl, Aufbereitung), aber keine direkte
/// StoreKit- oder Persistenzlogik.
@Observable
@MainActor
final class PaywallViewModel: ViewModel {

    /// Aktuell in der UI ausgewähltes Produkt (Standard: Empfehlung).
    var selectedProductID: String?

    /// Fehlermeldung für einen Alert (nil = kein Fehler).
    var errorMessage: String?

    /// Wird `true`, sobald Premium aktiv ist (View kann sich schließen).
    var didCompletePurchase = false

    private let service: SubscriptionServiceProtocol

    init(service: SubscriptionServiceProtocol) {
        self.service = service
    }

    // MARK: - Abgeleiteter Zustand

    var isLoading: Bool { service.isLoading }

    var isPremium: Bool { service.entitlementStatus.isPremium }

    /// Aufbereitete Produkte in Anzeige-Reihenfolge.
    var displayProducts: [ProductDisplayInfo] {
        service.products.compactMap(ProductDisplayInfo.init)
    }

    /// Ob mindestens ein Produkt eine kostenlose Testphase bietet.
    var hasAnyFreeTrial: Bool {
        displayProducts.contains { $0.hasFreeTrial }
    }

    /// Die Premium-Vorteile (statisch, für die Vorteils-Liste).
    let benefits: [PremiumBenefit] = PremiumBenefit.all

    // MARK: - Aktionen

    func onAppear() async {
        await service.loadProducts()
        if selectedProductID == nil {
            // Empfehlung vorauswählen, sonst erstes Produkt.
            selectedProductID = displayProducts.first(where: { $0.kind.isRecommended })?.product.id
                ?? displayProducts.first?.product.id
        }
        if isPremium { didCompletePurchase = true }
    }

    func select(_ info: ProductDisplayInfo) {
        selectedProductID = info.product.id
    }

    func purchaseSelected() async {
        guard let info = displayProducts.first(where: { $0.product.id == selectedProductID }) else {
            return
        }
        await purchase(info)
    }

    func purchase(_ info: ProductDisplayInfo) async {
        do {
            let result = try await service.purchase(info.product)
            switch result {
            case .success:
                didCompletePurchase = true
            case .pending, .cancelled:
                break
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func restore() async {
        await service.restore()
        if isPremium {
            didCompletePurchase = true
        } else {
            errorMessage = "Es wurden keine früheren Käufe gefunden."
        }
    }
}
