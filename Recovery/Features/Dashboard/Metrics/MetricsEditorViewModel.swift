import Foundation
import Observation

/// ViewModel des Metrik-Editors (MVVM).
///
/// Lädt und speichert die Fortschritts-Eingaben der aktiven Sucht über das
/// `RecoveryRepository`. Kennt keine Persistenzdetails. Die angezeigten
/// Felder richten sich nach der Metrik-Kategorie der Suchtart.
@MainActor
@Observable
final class MetricsEditorViewModel: ViewModel {

    private(set) var state: ViewState<Void> = .idle

    /// Suchtart, für die Werte erfasst werden (steuert die sichtbaren Felder).
    private(set) var habitType: HabitType = .smoking

    // MARK: - Eingabefelder (als Text, für TextField-Bindung)

    var unitPriceText = ""
    var unitsPerDayText = ""
    var unitsPerPackageText = ""
    var weeklySpendText = ""
    var drinksPerWeekText = ""
    var minutesPerDayText = ""

    private let repository: RecoveryRepository

    init(repository: RecoveryRepository) {
        self.repository = repository
    }

    /// Kategorie der aktiven Suchtart (Geld vs. Zeit).
    var category: HabitType.MetricCategory { habitType.metricCategory }

    var consumptionUnitName: String { habitType.consumptionUnitName }

    /// Konkretes Eingabe-Layout je Suchtart (steuert die sichtbaren Felder).
    enum InputLayout {
        /// Rauchen: Preis/Schachtel, Zigaretten/Tag, Zigaretten/Schachtel.
        case smokingPackage
        /// Alkohol: Wochenausgabe + optional Getränke/Woche.
        case alcoholWeekly
        /// Glücksspiel/Zucker: nur Wochenausgabe.
        case weeklySpendOnly
        /// Zeit-Süchte: Minuten pro Tag.
        case timePerDay
    }

    var inputLayout: InputLayout {
        switch habitType {
        case .smoking: return .smokingPackage
        case .alcohol: return .alcoholWeekly
        case .gambling, .sugar: return .weeklySpendOnly
        case .pornography, .socialMedia: return .timePerDay
        }
    }

    func onAppear() async {
        await load()
    }

    func load() async {
        state = .loading
        do {
            if let profile = try await repository.loadProfile() {
                habitType = profile.habitType
            }
            let metrics = try await repository.fetchMetrics()
            applyToFields(metrics)
            applyPlaceholderDefaults(existing: metrics)
            state = .loaded(())
        } catch {
            state = .failed(error)
        }
    }

    /// Speichert die aktuellen Eingaben. Gibt `true` bei Erfolg zurück.
    @discardableResult
    func save() async -> Bool {
        do {
            try await repository.updateMetrics(currentMetrics())
            return true
        } catch {
            state = .failed(error)
            return false
        }
    }

    // MARK: - Mapping Text ↔ Domain

    /// Setzt unverbindliche Platzhalter-Vorschläge (nur beim Rauchen und nur,
    /// wenn der Nutzer noch nichts eingetragen hat). Nicht erzwungen.
    private func applyPlaceholderDefaults(existing: AddictionMetrics) {
        guard habitType == .smoking else { return }
        if existing.unitPrice == nil, unitPriceText.isEmpty {
            unitPriceText = "8"
        }
        if existing.unitsPerPackage == nil, unitsPerPackageText.isEmpty {
            unitsPerPackageText = "20"
        }
    }

    private func applyToFields(_ metrics: AddictionMetrics) {
        unitPriceText = metrics.unitPrice.map { Self.decimalString($0) } ?? ""
        unitsPerDayText = metrics.unitsPerDay.map { Self.doubleString($0) } ?? ""
        unitsPerPackageText = metrics.unitsPerPackage.map { Self.doubleString($0) } ?? ""
        weeklySpendText = metrics.weeklySpend.map { Self.decimalString($0) } ?? ""
        drinksPerWeekText = metrics.drinksPerWeek.map { Self.doubleString($0) } ?? ""
        minutesPerDayText = metrics.minutesPerDay.map { Self.doubleString($0) } ?? ""
    }

    private func currentMetrics() -> AddictionMetrics {
        AddictionMetrics(
            unitPrice: Self.parseDecimal(unitPriceText),
            unitsPerDay: Self.parseDouble(unitsPerDayText),
            unitsPerPackage: Self.parseDouble(unitsPerPackageText),
            weeklySpend: Self.parseDecimal(weeklySpendText),
            drinksPerWeek: Self.parseDouble(drinksPerWeekText),
            minutesPerDay: Self.parseDouble(minutesPerDayText)
        )
    }

    // MARK: - Parsing-Helfer (akzeptiert Komma und Punkt)

    private static func normalized(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: ",", with: ".")
    }

    private static func parseDouble(_ text: String) -> Double? {
        let value = normalized(text)
        guard !value.isEmpty, let number = Double(value), number >= 0 else { return nil }
        return number
    }

    private static func parseDecimal(_ text: String) -> Decimal? {
        guard let number = parseDouble(text) else { return nil }
        return Decimal(number)
    }

    private static func doubleString(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(value)
    }

    private static func decimalString(_ value: Decimal) -> String {
        doubleString((value as NSDecimalNumber).doubleValue)
    }
}
