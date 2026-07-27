import Foundation
import Observation
import SwiftUI

/// ViewModel des Statistik-Screens (MVVM).
///
/// Lädt die Rohdaten über das `RecoveryRepository` und delegiert die
/// Berechnung an den `StatisticsCalculator`. Kennt keine Persistenz- oder
/// UI-Details.
@MainActor
@Observable
final class StatisticsViewModel: ViewModel {

    private(set) var state: ViewState<RecoveryStatistics> = .idle

    private let repository: RecoveryRepository

    init(repository: RecoveryRepository) {
        self.repository = repository
    }

    func onAppear() async {
        if case .loaded = state { return }
        await load()
    }

    /// Lädt die Statistik neu, ohne den Lade-Spinner zu zeigen
    /// (verhindert Flackern beim erneuten Öffnen des Tabs).
    func refresh() async {
        await load(showLoading: false)
    }

    func load(showLoading: Bool = true) async {
        if showLoading {
            state = .loading
        }
        do {
            guard let profile = try await repository.loadProfile() else {
                state = .failed(AppError.notFound)
                return
            }
            let relapses = try await repository.fetchRelapses()
            let journal = try await repository.fetchJournalEntries()
            let triggers = try await repository.fetchTriggers()

            let statistics = StatisticsCalculator.makeStatistics(
                profile: profile,
                relapses: relapses,
                journalEntries: journal,
                triggers: triggers
            )
            state = .loaded(statistics)
        } catch {
            state = .failed(error)
        }
    }

    // MARK: - Aufbereitete Kennzahlen (für die Karten)

    /// Kennzahl-Karten in fester Reihenfolge (Grid 2×2).
    func metricCards(for statistics: RecoveryStatistics) -> [StatMetric] {
        [
            StatMetric(
                id: "currentStreak",
                value: statistics.currentStreakDays,
                unit: "Tage",
                label: "Aktuelle Streak",
                systemImage: "flame.fill",
                tint: .orange
            ),
            StatMetric(
                id: "longestStreak",
                value: statistics.longestStreakDays,
                unit: "Tage",
                label: "Längste Streak",
                systemImage: "trophy.fill",
                tint: .yellow
            ),
            StatMetric(
                id: "relapses",
                value: statistics.relapseCount,
                unit: nil,
                label: "Rückfälle",
                systemImage: "arrow.uturn.backward",
                tint: .red
            ),
            StatMetric(
                id: "triggers",
                value: statistics.topTriggers.count,
                unit: nil,
                label: "Erfasste Trigger",
                systemImage: "bolt.fill",
                tint: .blue
            )
        ]
    }
}

/// Aufbereitete Kennzahl für eine `StatCard`. Reines Presentation-Modell.
struct StatMetric: Identifiable, Equatable {
    let id: String
    let value: Int
    let unit: String?
    let label: String
    let systemImage: String
    let tint: Color
}
