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
                LazyVGrid(columns: columns, spacing: AppSpacing.m) {
                    StatCard(
                        value: "\(statistics.currentStreakDays)",
                        label: "Aktuelle Streak",
                        systemImage: "flame.fill"
                    )
                    StatCard(
                        value: "\(statistics.longestStreakDays)",
                        label: "Längste Streak",
                        systemImage: "trophy.fill",
                        tint: .yellow
                    )
                    StatCard(
                        value: "\(statistics.relapseCount)",
                        label: "Rückfälle",
                        systemImage: "arrow.uturn.backward",
                        tint: .red
                    )
                    StatCard(
                        value: "\(statistics.topTriggers.count)",
                        label: "Erfasste Trigger",
                        systemImage: "bolt.fill",
                        tint: .orange
                    )
                }

                TopTriggersChart(triggers: statistics.topTriggers)
            }
            .padding(AppSpacing.m)
            .premiumGated(.alleStatistiken) {
                SampleChartPreview()
            }
        }
    }
}

#Preview {
    StatisticsView()
}
