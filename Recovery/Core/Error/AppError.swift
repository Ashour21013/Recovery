import Foundation

/// Zentraler, app-weiter Fehlertyp.
///
/// Konkrete Schichten mappen ihre technischen Fehler auf diesen Typ,
/// damit die Presentation-Schicht einheitliche, nutzerfreundliche
/// Meldungen anzeigen kann.
enum AppError: Error, Equatable {
    case persistence
    case notFound
    case unknown
}
