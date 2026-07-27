import Foundation

/// Zentrale Konstanten für die geteilte App Group zwischen Haupt-App und
/// Widget-Extension.
///
/// Die App Group muss in Xcode für BEIDE Targets (App + Widget) unter
/// "Signing & Capabilities → App Groups" mit exakt dieser ID aktiviert werden.
enum AppGroup {

    /// Gemeinsame App-Group-ID (App-Target UND Widget-Target).
    static let identifier = "group.no.Recovery"

    /// Geteilter `UserDefaults`-Speicher der App Group (nil, falls die
    /// Capability noch nicht eingerichtet ist).
    static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: identifier)
    }
}
