import SwiftUI

/// Statistik-Screen: Kennzahlen und Trigger-Auswertung.
///
/// Bindet an das `StatisticsViewModel` und greift nie direkt auf SwiftData
/// zu. Die einzelnen Bausteine (Kennzahl-Karten, Chart) sind ausgelagert.
struct StatisticsView: View {

    @Environment(\.dependencies) private var dependencies
    @State private var viewModel: StatisticsViewModel?

    private let columns = [
        GridItem(.flexible(), spacing: AppSpacing.m),
        GridItem(.flexible(), spacing: AppSpacing.m)
    ]

    var body: some View {
        NavigationStack {
            content
                .animation(.smooth, value: viewModel?.state)
                .navigationTitle("Statistik")
                .background(Color(.systemGroupedBackground))
        }
        .task {
            if viewModel == nil {
                viewModel = StatisticsViewModel(repository: dependencies.makeRecoveryRepository())
            }
            await viewModel?.onAppear()
        }
        .onAppear {
            // Bei jedem Wechsel auf diesen Tab die Kennzahlen aktualisieren.
            Task { await viewModel?.refresh() }
        }
        .onReceive(NotificationCenter.default.publisher(for: .activeAddictionDidChange)) { _ in
            Task { await viewModel?.refresh() }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel?.state {
        case .loaded(let statistics):
            loadedContent(statistics)
                .transition(.opacity)

        case .failed:
            ContentUnavailableView(
                "Keine Daten",
                systemImage: "chart.bar.xaxis",
                description: Text("Sobald du startest, erscheinen hier deine Statistiken.")
            )

        default:
            ProgressView("Lädt…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func loadedContent(_ statistics: RecoveryStatistics) -> some View {
        ScrollView {
            VStack(spacing: AppSpacing.m) {
                metricsGrid(statistics)
                StreakHistoryChart(points: statistics.streakHistory)
                RelapseHistoryChart(buckets: statistics.relapseBuckets)
                TopTriggersChart(triggers: statistics.topTriggers)
            }
            .padding(AppSpacing.m)
            .premiumGated(.alleStatistiken) {
                SampleChartPreview()
            }
        }
    }

    @ViewBuilder
    private func metricsGrid(_ statistics: RecoveryStatistics) -> some View {
        if let viewModel {
            LazyVGrid(columns: columns, spacing: AppSpacing.m) {
                ForEach(viewModel.metricCards(for: statistics)) { metric in
                    StatMetricCard(metric: metric)
                }
            }
        }
    }
}

#Preview {
    StatisticsView()
}
