import Foundation

/// Nutzer-Eingaben zur Berechnung der Fortschritts-Gewinne einer Sucht.
///
/// Je nach Suchtart sind unterschiedliche Felder relevant:
/// - Finanzielle Süchte (Rauchen, Alkohol, Glücksspiel): `unitPrice` und
///   `unitsPerDay` bzw. `weeklySpend`.
/// - Nicht-finanzielle Süchte (Pornografie, Social Media): `minutesPerDay`.
///
/// Alle Felder sind optional – fehlen Eingaben, zeigt das Dashboard einen
/// dezenten Hinweis statt falscher Zahlen. Reine Domain-Entität.
struct AddictionMetrics: Equatable {

    /// Preis pro Konsumeinheit (z. B. Preis pro Schachtel Zigaretten).
    var unitPrice: Decimal?
    /// Konsumeinheiten pro Tag (z. B. Zigaretten pro Tag).
    var unitsPerDay: Double?
    /// Anzahl Einheiten pro Preis-Packung (z. B. 20 Zigaretten pro Schachtel).
    var unitsPerPackage: Double?
    /// Alternativ: durchschnittliche Ausgaben pro Woche (Alkohol/Glücksspiel).
    var weeklySpend: Decimal?
    /// Durchschnittlich verbrauchte Zeit pro Tag in Minuten (Zeit-Süchte).
    var minutesPerDay: Double?

    init(
        unitPrice: Decimal? = nil,
        unitsPerDay: Double? = nil,
        unitsPerPackage: Double? = nil,
        weeklySpend: Decimal? = nil,
        minutesPerDay: Double? = nil
    ) {
        self.unitPrice = unitPrice
        self.unitsPerDay = unitsPerDay
        self.unitsPerPackage = unitsPerPackage
        self.weeklySpend = weeklySpend
        self.minutesPerDay = minutesPerDay
    }

    /// Leere Eingaben (keine Werte hinterlegt).
    static let empty = AddictionMetrics()

    /// Ob überhaupt verwertbare Eingaben vorliegen.
    var hasAnyInput: Bool {
        unitPrice != nil || unitsPerDay != nil || weeklySpend != nil || minutesPerDay != nil
    }
}
