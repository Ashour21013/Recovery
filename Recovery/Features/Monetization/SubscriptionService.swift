import Foundation
import StoreKit
import Observation

/// StoreKit-2-Implementierung des `SubscriptionServiceProtocol`.
///
/// Kapselt das komplette IAP-Handling: Produkte laden, kaufen, wiederherstellen,
/// Entitlements prüfen (`Transaction.currentEntitlements`) und auf
/// Transaktions-Updates lauschen (`Transaction.updates`). Als `@Observable`
/// wird der Status app-weit in der Environment beobachtbar bereitgestellt.
@Observable
@MainActor
final class SubscriptionService: SubscriptionServiceProtocol {

    private(set) var entitlementStatus: EntitlementStatus = .unknown
    private(set) var products: [Product] = []
    private(set) var isLoading = false

    /// Hintergrund-Task, der auf Transaktions-Updates lauscht.
    @ObservationIgnored
    private var updatesTask: Task<Void, Never>?

    /// Spiegelt den Premium-Status in die App Group für das Widget.
    @ObservationIgnored
    private let widgetStore = WidgetSnapshotStore()

    init() {
        // Auf Transaktions-Updates lauschen, solange der Service lebt.
        updatesTask = listenForTransactions()
    }

    deinit {
        updatesTask?.cancel()
    }

    // MARK: - Produkte laden

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let storeProducts = try await Product.products(for: SubscriptionProduct.allProductIDs)
            self.products = sort(storeProducts)
        } catch {
            self.products = []
        }
        await refreshEntitlements()
    }

    /// Sortiert Produkte in der Anzeige-Reihenfolge Monatlich → Jährlich → Lifetime.
    private func sort(_ products: [Product]) -> [Product] {
        let order = SubscriptionProduct.allCases.map(\.rawValue)
        return products.sorted { lhs, rhs in
            (order.firstIndex(of: lhs.id) ?? .max) < (order.firstIndex(of: rhs.id) ?? .max)
        }
    }

    // MARK: - Kauf

    @discardableResult
    func purchase(_ product: Product) async throws -> PurchaseResult {
        isLoading = true
        defer { isLoading = false }

        let result = try await product.purchase()
        switch result {
        case let .success(verification):
            let transaction = try checkVerified(verification)
            await refreshEntitlements()
            await transaction.finish()
            return .success

        case .pending:
            return .pending

        case .userCancelled:
            return .cancelled

        @unknown default:
            throw SubscriptionError.unknown
        }
    }

    // MARK: - Restore

    func restore() async {
        isLoading = true
        defer { isLoading = false }
        // Synchronisiert Transaktionen mit dem App Store und aktualisiert Status.
        try? await AppStore.sync()
        await refreshEntitlements()
    }

    // MARK: - Entitlements

    func refreshEntitlements() async {
        var active: SubscriptionProduct?

        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else { continue }
            // Widerrufene/abgelaufene Transaktionen ignorieren.
            if transaction.revocationDate != nil { continue }
            if let expiration = transaction.expirationDate, expiration < .now { continue }

            if let product = SubscriptionProduct(rawValue: transaction.productID) {
                // Lifetime hat Vorrang, sonst erstes aktives Abo.
                if product == .lifetime {
                    active = .lifetime
                    break
                }
                if active == nil {
                    active = product
                }
            }
        }

        entitlementStatus = active.map(EntitlementStatus.subscribed) ?? .notSubscribed

        // Premium-Status zuverlässig für das Home-Screen-Widget spiegeln.
        widgetStore.updatePremium(entitlementStatus.isPremium)
    }

    // MARK: - Transaktions-Updates

    private func listenForTransactions() -> Task<Void, Never> {
        Task(priority: .background) { [weak self] in
            for await update in Transaction.updates {
                guard let self else { continue }
                guard let transaction = try? await self.verify(update) else { continue }
                await self.refreshEntitlements()
                await transaction.finish()
            }
        }
    }

    // MARK: - Verifikation

    /// Async-Wrapper für den Zugriff aus dem (nicht isolierten) Update-Listener.
    private func verify<T>(_ result: VerificationResult<T>) throws -> T {
        try checkVerified(result)
    }

    /// Stellt sicher, dass eine Transaktion von StoreKit signiert/verifiziert ist.
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw SubscriptionError.failedVerification
        case let .verified(safe):
            return safe
        }
    }
}
