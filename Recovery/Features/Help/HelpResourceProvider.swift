import Foundation

/// Abstraktion für die Quelle der Hilfe-/Beratungs-Ressourcen.
///
/// Die Presentation-Schicht kennt ausschließlich dieses Protokoll, nie die
/// konkrete Datenquelle (Dependency Inversion). Dadurch lassen sich
/// Ressourcen leicht ergänzen oder z. B. später aus einer Remote-Quelle
/// laden, ohne die View zu ändern.
protocol HelpResourceProvider {

    /// Appeigene Selbsthilfe-Ressourcen (Craving Mode, Atemübung, Plan …).
    func inAppResources() -> [HelpResource]

    /// Externe, offizielle Angebote – gruppiert nach Region.
    ///
    /// Die Reihenfolge der Regionen bestimmt die Anzeige-Reihenfolge.
    func externalResources() -> [(region: SupportRegion, resources: [HelpResource])]
}
