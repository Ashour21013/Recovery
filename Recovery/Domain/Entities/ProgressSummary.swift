import Foundation

/// Zusammenfassung des Gesamtfortschritts für die Fortschrittskarte.
/// Reine Domain-Entität ohne UI-Bezug.
struct ProgressSummary: Equatable {
    /// Anteil zum nächsten Meilenstein (0.0 – 1.0).
    let milestoneFraction: Double
    /// Bezeichnung des nächsten Meilensteins (z. B. "30 Tage").
    let nextMilestoneTitle: String
    /// Gesparter Geldbetrag seit Beginn.
    let moneySaved: Decimal
    /// Währungssymbol für die Anzeige.
    let currencyCode: String
    /// Anzahl vermiedener "Rückfälle"/Konsumeinheiten.
    let avoidedCount: Int

    var clampedMilestoneFraction: Double { min(1.0, max(0.0, milestoneFraction)) }
}
