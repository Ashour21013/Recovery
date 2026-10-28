import Foundation
import FamilyControls
import ManagedSettings

/// Inhaltsschutz über Apples Screen-Time-API.
///
/// - Web-Filter: `webContent.blockedByFilter = .auto(...)` aktiviert den
///   systemweiten Filter für Websites für Erwachsene (Safari & WebViews).
/// - Shields: sperrt vom Nutzer gewählte Apps/Kategorien/Websites.
///
/// Benötigt das Entitlement `com.apple.developer.family-controls` und ein
/// echtes Gerät.
@MainActor
final class ScreenTimeContentBlockingService: ContentBlockingService {

    private let store = ManagedSettingsStore()

    let isSimulated = false

    var authorization: ContentBlockingAuthorization {
        switch AuthorizationCenter.shared.authorizationStatus {
        case .approved: .approved
        case .denied: .denied
        case .notDetermined: .notDetermined
        default: .notDetermined
        }
    }

    func requestAuthorization() async throws {
        try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
    }

    func applyWebFilter(extraBlockedDomains: Set<String>) {
        let domains = Set(extraBlockedDomains.map { WebDomain(domain: $0) })
        store.webContent.blockedByFilter = .auto(domains)
    }

    func applyShield(_ selection: FamilyActivitySelection) {
        store.shield.applications = selection.applicationTokens.isEmpty
            ? nil : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty
            ? nil : .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens.isEmpty
            ? nil : selection.webDomainTokens
    }

    func removeAll() {
        store.clearAllSettings()
    }
}

/// Ersatz für den Simulator, in dem Screen Time nicht verfügbar ist.
///
/// Speichert nur den Zustand und protokolliert die Aufrufe, damit der
/// komplette UI-Ablauf im Simulator testbar ist. Es wird NICHTS gesperrt –
/// die UI weist darauf hin (`isSimulated`).
@MainActor
final class SimulatedContentBlockingService: ContentBlockingService {

    private(set) var authorization: ContentBlockingAuthorization = .notDetermined
    let isSimulated = true

    private(set) var appliedDomains: Set<String> = []
    private(set) var isFilterActive = false

    func requestAuthorization() async throws {
        authorization = .approved
        log("Berechtigung erteilt (simuliert)")
    }

    func applyWebFilter(extraBlockedDomains: Set<String>) {
        isFilterActive = true
        appliedDomains = extraBlockedDomains
        log("Web-Filter aktiv, zusätzliche Domains: \(extraBlockedDomains.sorted())")
    }

    func applyShield(_ selection: FamilyActivitySelection) {
        log("Shield: \(selection.applicationTokens.count) Apps, \(selection.categoryTokens.count) Kategorien, \(selection.webDomainTokens.count) Websites")
    }

    func removeAll() {
        isFilterActive = false
        appliedDomains = []
        log("Alle Sperren aufgehoben")
    }

    private func log(_ message: String) {
        #if DEBUG
        print("[ContentBlocking] \(message)")
        #endif
    }
}
