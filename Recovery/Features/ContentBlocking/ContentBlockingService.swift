import Foundation
import FamilyControls

/// Berechtigungsstatus für die Screen-Time-Funktionen.
enum ContentBlockingAuthorization: Equatable {
    case notDetermined
    case denied
    case approved
}

/// Abstraktion des Inhaltsschutzes (Pornografie-Filter + App-/Website-Sperren).
///
/// ViewModels kennen nur dieses Protokoll – die konkrete Umsetzung
/// (Screen-Time-API bzw. Simulator-Ersatz) wird im Composition Root gewählt.
@MainActor
protocol ContentBlockingService: AnyObject {
    /// Aktueller Berechtigungsstatus.
    var authorization: ContentBlockingAuthorization { get }

    /// `true`, wenn Sperren nur simuliert werden (z. B. im Simulator).
    var isSimulated: Bool { get }

    /// Fragt die Screen-Time-Berechtigung an (Systemdialog mit Face ID/Code).
    func requestAuthorization() async throws

    /// Aktiviert Apples Filter für Websites für Erwachsene und sperrt
    /// zusätzlich die angegebenen Domains.
    func applyWebFilter(extraBlockedDomains: Set<String>)

    /// Sperrt die vom Nutzer ausgewählten Apps, Kategorien und Websites.
    func applyShield(_ selection: FamilyActivitySelection)

    /// Hebt alle Sperren auf.
    func removeAll()
}
