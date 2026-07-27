import Foundation
import Observation

/// ViewModel des Einstellungen-Screens (MVVM).
///
/// Kapselt die Aktionen für Datenschutz, Feedback, Bewertung, Datenexport
/// und das Löschen aller Daten. Kennt keine SwiftData- oder UI-Details –
/// es arbeitet ausschließlich über das `RecoveryRepository`.
@MainActor
@Observable
final class SettingsViewModel: ViewModel {

    /// Ergebnis eines vorbereiteten Exports (temporäre Datei zum Teilen).
    private(set) var exportURL: URL?

    /// Steuert die Anzeige des Lösch-Bestätigungsdialogs.
    var isConfirmingDeletion = false

    /// Signalisiert, dass alle Daten gelöscht wurden (z. B. Onboarding neu).
    private(set) var didDeleteAllData = false

    /// Läuft gerade ein Export?
    private(set) var isExporting = false

    /// Benutzerfreundliche Fehlermeldung, falls eine Aktion fehlschlägt.
    var errorMessage: String?

    /// Bestätigungsmeldung nach erfolgreicher Aktion (z. B. Wiederherstellung).
    var infoMessage: String?

    /// Läuft gerade eine Wiederherstellung früherer Käufe?
    private(set) var isRestoring = false

    /// Angezeigte App-Version.
    let appVersion = AppInfo.fullVersion

    private let repository: RecoveryRepository
    private let subscriptionService: SubscriptionServiceProtocol

    init(repository: RecoveryRepository, subscriptionService: SubscriptionServiceProtocol) {
        self.repository = repository
        self.subscriptionService = subscriptionService
    }

    // MARK: - Abonnement / Premium

    /// Ob der Nutzer aktuell Premium-Zugriff hat.
    var isPremium: Bool {
        subscriptionService.entitlementStatus.isPremium
    }

    /// Stellt frühere Käufe wieder her (immer verfügbar, ohne Premium-Gate).
    ///
    /// Löst den bestehenden Restore-Flow des `SubscriptionService` aus,
    /// aktualisiert danach den Premium-Status und zeigt eine passende
    /// Rückmeldung an.
    func restorePurchases() async {
        guard !isRestoring else { return }
        isRestoring = true
        defer { isRestoring = false }

        await subscriptionService.restore()

        if isPremium {
            infoMessage = "Deine Käufe wurden wiederhergestellt. Premium ist aktiv."
        } else {
            infoMessage = "Es wurden keine früheren Käufe gefunden, die wiederhergestellt werden können."
        }
    }


    // MARK: - Datenexport

    /// Erstellt eine temporäre JSON-Datei mit allen Daten zum Teilen.
    func exportData() async {
        guard !isExporting else { return }
        isExporting = true
        defer { isExporting = false }

        do {
            let data = try await repository.exportData()
            let json = try data.makeJSONData()
            let url = try writeTemporaryFile(json)
            exportURL = url
        } catch {
            errorMessage = "Der Export ist fehlgeschlagen. Bitte versuche es erneut."
        }
    }

    /// Räumt die Export-Datei nach dem Teilen wieder auf.
    func clearExport() {
        if let exportURL {
            try? FileManager.default.removeItem(at: exportURL)
        }
        exportURL = nil
    }

    // MARK: - Daten löschen

    func requestDeletion() {
        isConfirmingDeletion = true
    }

    /// Löscht unwiderruflich alle Daten.
    func confirmDeletion() async {
        do {
            try await repository.deleteAllData()
            didDeleteAllData = true
        } catch {
            errorMessage = "Die Daten konnten nicht gelöscht werden."
        }
    }

    // MARK: - Private

    private func writeTemporaryFile(_ data: Data) throws -> URL {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let filename = "Recovery-Export-\(formatter.string(from: .now)).json"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try data.write(to: url, options: .atomic)
        return url
    }
}
