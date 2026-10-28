import Foundation
import StoreKit

/// Fehler, die beim Kauf-Flow auftreten können.
enum SubscriptionError: LocalizedError {
    case failedVerification
    case pending
    case cancelled
    case unknown

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return String(localized: "Der Kauf konnte nicht verifiziert werden.")
        case .pending:
            return String(localized: "Der Kauf steht noch aus (z. B. Freigabe erforderlich).")
        case .cancelled:
            return String(localized: "Der Kauf wurde abgebrochen.")
        case .unknown:
            return String(localized: "Ein unbekannter Fehler ist aufgetreten.")
        }
    }
}

/// Ergebnis eines Kaufversuchs.
enum PurchaseResult: Equatable {
    case success
    case pending
    case cancelled
}
