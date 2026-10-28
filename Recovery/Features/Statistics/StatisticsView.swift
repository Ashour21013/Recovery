import SwiftUI

/// Statistik-Screen: Kennzahlen und Trigger-Auswertung.
///
/// Bindet an das `StatisticsViewModel` und greift nie direkt auf SwiftData
/// zu. Die einzelnen Bausteine (Kennzahl-Karten, Chart) sind ausgelagert.
struct StatisticsView: View {

    @Environment(\.dependencies) private var dependencies
    @State private var viewModel: StatisticsViewModel?

    private let columns = [
        GridItem(.flexible(), spacing: 9),
        GridItem(.flexible(), spacing: 9)
    ]

    var body: some View {
        NavigationStack {
            content
                .animation(.smooth, value: viewModel?.state)
                .navigationTitle("Statistik")
                .background(AppColor.background.ignoresSafeArea())
                .tint(AppColor.teal)
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
            VStack(spacing: 12) {
                header
                metricsGrid(statistics)
                StreakHistoryChart(points: statistics.streakHistory)
                RelapseHistoryChart(buckets: statistics.relapseBuckets)
                TopTriggersChart(triggers: statistics.topTriggers)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .premiumGated(.alleStatistiken) {
                SampleChartPreview()
            }
        }
    }

    private var header: some View {
        Text("Dein Fortschritt wird sichtbar.")
            .font(AppFont.subheadline)
            .foregroundStyle(AppColor.muted)
            .frame(maxWidth: .infinity, alignment: .leading)
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
