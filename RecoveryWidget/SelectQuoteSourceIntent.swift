import WidgetKit
import AppIntents

/// Im Widget auswählbare Spruch-Quelle (App-Intents-Enum).
///
/// Spiegelt `WidgetQuoteSource`. Bewusst eigener `AppEnum`, da App Intents
/// eigene Konformitäten für die Auswahl-UI benötigt. Reine Auswahl – keine
/// Business-Logik im Widget.
enum QuoteSourceAppEnum: String, AppEnum {
    case quotes
    case science
    case bible
    case mixed

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Quelle"

    static var caseDisplayRepresentations: [QuoteSourceAppEnum: DisplayRepresentation] = [
        .quotes: "Motivationszitate",
        .science: "Wissenschaft",
        .bible: "Bibelverse",
        .mixed: "Gemischt"
    ]

    /// Abbildung auf die geteilte Transport-Enum.
    var widgetSource: WidgetQuoteSource {
        WidgetQuoteSource(rawValue: rawValue) ?? .quotes
    }
}

/// Konfigurations-Intent des Motivations-Widgets: erlaubt die Auswahl der
/// Spruch-Quelle (Long-Press → Widget bearbeiten).
struct SelectQuoteSourceIntent: WidgetConfigurationIntent {

    static var title: LocalizedStringResource = "Quelle auswählen"
    static var description = IntentDescription("Wähle, aus welcher Quelle die täglichen Sprüche stammen.")

    /// Gewählte Quelle – Standard sind die Motivationszitate (kostenlos).
    @Parameter(title: "Quelle", default: .quotes)
    var source: QuoteSourceAppEnum

    static var parameterSummary: some ParameterSummary {
        Summary("Sprüche aus \(\.$source)")
    }

    init() {}

    init(source: QuoteSourceAppEnum) {
        self.source = source
    }
}
