import Foundation
import Observation

/// ViewModel des Dashboards (MVVM).
///
/// Hält den Präsentationszustand des Dashboards und lädt die anzuzeigenden
/// Daten. Aktuell werden bewusst Mockdaten verwendet (keine Persistenz,
/// keine Use Cases). Die Struktur ist so gewählt, dass das Laden später
/// transparent durch einen Use Case ersetzt werden kann.
@MainActor
@Observable
final class DashboardViewModel: ViewModel {

    /// Ladezustand des Dashboards (Loading-/Error-/Content-Handling).
    private(set) var state: ViewState<DashboardData> = .idle

    /// Steuert die Anzeige des Cravings-Hilfe-Sheets.
    var isShowingCravingHelp = false

    /// Lädt die Dashboard-Daten. Aktuell aus einer Mock-Quelle.
    func onAppear() {
        guard case .idle = state else { return }
        load()
    }

    func load() {
        state = .loading
        // Später: Use Case aufrufen (async). Vorerst synchrone Mockdaten.
        state = .loaded(DashboardMockData.sample)
    }

    /// Nutzer meldet akutes Verlangen ("Cravings").
    func handleCravingTapped() {
        isShowingCravingHelp = true
    }

    // MARK: - Aufbereitete Anzeige-Werte

    /// Formatiert den gesparten Betrag gemäß Locale.
    func formattedMoneySaved(for progress: ProgressSummary) -> String {
        progress.moneySaved.formatted(
            .currency(code: progress.currencyCode)
        )
    }
}
