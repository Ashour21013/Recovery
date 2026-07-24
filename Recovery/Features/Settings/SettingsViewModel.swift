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

    /// Angezeigte App-Version.
    let appVersion = AppInfo.fullVersion

    private let repository: RecoveryRepository

    init(repository: RecoveryRepository) {
        self.repository = repository
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
