import Foundation

/// Marker-Basisprotokoll für alle Repositories.
///
/// Repositories abstrahieren den Datenzugriff. Die Domain-Schicht kennt
/// nur diese Protokolle, niemals die konkrete Persistenz (SwiftData, Netzwerk).
/// Dadurch bleibt die Geschäftslogik testbar und austauschbar
/// (Dependency Inversion Principle).
protocol Repository { }
