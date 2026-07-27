import Foundation

/// Klassifiziert Suchtarten nach der sinnvollsten Fortschritts-Metrik.
///
/// Entkoppelt die Provider-Auswahl von der konkreten Suchtart, sodass neue
/// Süchte nur hier eingeordnet werden müssen (Open/Closed-Prinzip).
extension HabitType {

    /// Bevorzugte Metrik-Kategorie einer Suchtart.
    enum MetricCategory {
        /// Gespartes Geld + vermiedene Menge (Rauchen, Alkohol, Glücksspiel).
        case money
        /// Zurückgewonnene Zeit (Pornografie, Social Media).
        case time
    }

    /// Die für diese Suchtart passende Metrik-Kategorie.
    var metricCategory: MetricCategory {
        switch self {
        case .smoking, .alcohol, .gambling, .sugar:
            return .money
        case .pornography, .socialMedia:
            return .time
        }
    }

    /// Bezeichnung der Konsumeinheit (für Eingabe/Anzeige bei Geld-Süchten).
    var consumptionUnitName: String {
        switch self {
        case .smoking: "Zigaretten"
        case .alcohol: "Getränke"
        case .gambling: "Wetten"
        case .sugar: "Snacks"
        case .pornography, .socialMedia: "Einheiten"
        }
    }
}
