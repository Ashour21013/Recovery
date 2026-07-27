import Foundation

/// Ein einzelner "Fortschritts-Gewinn" einer Recovery-Reise.
///
/// Vereinheitlicht unterschiedliche Metriken (Geld, Zeit, Menge) in einem
/// gemeinsamen, UI-neutralen Modell. So kann eine einzige Karten-Komponente
/// (`RecoveryGainCard`) alle Typen einheitlich darstellen, während die
/// konkrete Berechnung in den jeweiligen Providern liegt (SRP).
struct RecoveryGain: Identifiable, Equatable {

    /// Art der Metrik – bestimmt Formatierung und Semantik.
    enum Kind: String {
        case money
        case time
        case quantity
        /// Motivierender, nicht-medizinischer Gesundheits-Meilenstein.
        case health
    }

    let id: String
    let kind: Kind
    /// Roh-Wert (z. B. Euro-Betrag, Stunden, Stückzahl). Bei `health` ungenutzt.
    let value: Double
    /// Einheit bzw. Währungscode (bei `money` ein ISO-Code wie "EUR").
    let unit: String
    /// Kurzer Titel der Kennzahl (z. B. "Gespart", "Zurückgewonnen").
    let title: String
    /// Motivierende Beschreibung (z. B. "Entspricht 3 Arbeitstagen").
    let detail: String
    /// SF-Symbol für die Darstellung.
    let systemImage: String

    /// Anzeigefertiger, lokalisierter Wert – je nach `kind` formatiert.
    /// Bei `health` leer, da dort nur Titel + Beschreibung zählen.
    var formattedValue: String {
        switch kind {
        case .money:
            return Decimal(value).formatted(.currency(code: unit))
        case .time:
            let rounded = (value * 10).rounded() / 10
            return "\(Self.trim(rounded)) \(unit)"
        case .quantity:
            return "\(Int(value.rounded())) \(unit)"
        case .health:
            return ""
        }
    }

    /// Entfernt überflüssige Nachkommastellen (z. B. 3.0 → "3").
    private static func trim(_ value: Double) -> String {
        value == value.rounded()
            ? String(Int(value))
            : String(format: "%.1f", value)
    }
}
