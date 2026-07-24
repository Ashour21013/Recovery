import Foundation

/// Liefert App-Metadaten (Version, Build) aus dem Bundle.
/// Reine Hilfsstruktur ohne UI-Bezug.
enum AppInfo {
    /// Marketing-Version, z. B. „1.0".
    static var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    /// Build-Nummer, z. B. „1".
    static var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    /// Kombinierte Anzeige, z. B. „1.0 (1)".
    static var fullVersion: String {
        "\(version) (\(build))"
    }
}
