import Foundation
import FamilyControls

/// ViewModel des Inhaltsschutzes.
///
/// Steuert Aktivierung (inkl. Berechtigung), eigene Domains, App-Auswahl
/// und die bewusste Deaktivierungs-Hürde (Countdown).
@Observable
@MainActor
final class ContentBlockingViewModel {

    // MARK: - Zustand

    private(set) var isEnabled: Bool
    private(set) var authorization: ContentBlockingAuthorization
    private(set) var customDomains: [String]
    private(set) var isWorking = false
    /// Laufende Deaktivierungs-Hürde (nil = keine).
    private(set) var countdown: DeactivationCountdown?

    var selection: FamilyActivitySelection
    var newDomainInput = ""
    var errorMessage: String?
    var isShowingAppPicker = false

    var isSimulated: Bool { service.isSimulated }

    /// Kurzbeschreibung der gewählten Apps/Kategorien/Websites.
    var selectionSummary: String {
        let apps = selection.applicationTokens.count
        let categories = selection.categoryTokens.count
        let sites = selection.webDomainTokens.count
        if apps + categories + sites == 0 { return String(localized: "Keine ausgewählt") }
        var parts: [String] = []
        if apps > 0 { if apps == 1 { parts.append(String(localized: "1 App")) } else { parts.append(String(localized: "\(apps) Apps")) } }
        if categories > 0 { if categories == 1 { parts.append(String(localized: "1 Kategorie")) } else { parts.append(String(localized: "\(categories) Kategorien")) } }
        if sites > 0 { if sites == 1 { parts.append(String(localized: "1 Website")) } else { parts.append(String(localized: "\(sites) Websites")) } }
        return parts.joined(separator: ", ")
    }

    // MARK: - Abhängigkeiten

    private let service: ContentBlockingService
    private let store: ContentBlockingSettingsStore
    private let countdownDuration: Int
    private var countdownTask: Task<Void, Never>?

    init(
        service: ContentBlockingService,
        store: ContentBlockingSettingsStore,
        countdownDuration: Int = DeactivationCountdown.defaultDuration
    ) {
        self.service = service
        self.store = store
        self.countdownDuration = countdownDuration
        self.isEnabled = store.isEnabled
        self.authorization = service.authorization
        self.customDomains = store.customDomains
        if let data = store.selectionData,
           let decoded = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            self.selection = decoded
        } else {
            self.selection = FamilyActivitySelection()
        }
    }

    // MARK: - Lebenszyklus

    /// Aktualisiert den Berechtigungsstatus und setzt aktive Sperren erneut
    /// (z. B. nach App-Neustart oder Berechtigungsänderung).
    func onAppear() {
        authorization = service.authorization
        if isEnabled && authorization == .approved {
            applyAll()
        }
    }

    // MARK: - Aktivieren

    func enable() async {
        guard !isEnabled else { return }
        isWorking = true
        defer { isWorking = false }

        if service.authorization != .approved {
            do {
                try await service.requestAuthorization()
            } catch {
                authorization = service.authorization
                errorMessage = String(localized: "Die Bildschirmzeit-Berechtigung wurde nicht erteilt. Ohne sie kann der Schutz nicht aktiviert werden.")
                return
            }
        }
        authorization = service.authorization
        guard authorization == .approved else {
            errorMessage = String(localized: "Die Bildschirmzeit-Berechtigung wurde nicht erteilt.")
            return
        }

        isEnabled = true
        store.isEnabled = true
        applyAll()
    }

    // MARK: - Eigene Domains

    func addDomain() {
        guard let domain = DomainNormalizer.normalize(newDomainInput) else {
            errorMessage = String(localized: "„\(newDomainInput)“ ist keine gültige Domain. Beispiel: beispiel.com")
            return
        }
        guard !customDomains.contains(domain) else {
            newDomainInput = ""
            return
        }
        customDomains.append(domain)
        customDomains.sort()
        store.customDomains = customDomains
        newDomainInput = ""
        if isEnabled { applyAll() }
    }

    func removeDomains(at offsets: IndexSet) {
        customDomains = customDomains.enumerated()
            .filter { !offsets.contains($0.offset) }
            .map(\.element)
        store.customDomains = customDomains
        if isEnabled { applyAll() }
    }

    // MARK: - App-Auswahl

    func selectionDidChange() {
        store.selectionData = try? JSONEncoder().encode(selection)
        if isEnabled { applyAll() }
    }

    // MARK: - Deaktivieren (mit Hürde)

    func startDeactivation() {
        guard isEnabled, countdown == nil else { return }
        countdown = DeactivationCountdown(duration: countdownDuration)
        countdownTask?.cancel()
        countdownTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard let self, !Task.isCancelled, var current = self.countdown else { return }
                current.tick()
                self.countdown = current
                if current.isFinished { return }
            }
        }
    }

    func cancelDeactivation() {
        countdownTask?.cancel()
        countdownTask = nil
        countdown = nil
    }

    /// Schaltet den Schutz ab – nur nach abgelaufenem Countdown.
    func confirmDeactivation() {
        guard let countdown, countdown.isFinished else { return }
        service.removeAll()
        isEnabled = false
        store.isEnabled = false
        cancelDeactivation()
    }

    // MARK: - Privat

    private func applyAll() {
        service.applyWebFilter(extraBlockedDomains: Set(customDomains))
        service.applyShield(selection)
    }
}
