import SwiftUI

/// Dashboard-Screen der App.
///
/// Setzt die einzelnen Sektionen (Streak, Motivation, Cravings-Button,
/// Fortschritt, Tagesziel) zusammen. Die View enthält keine
/// Geschäftslogik – sie bindet an das `DashboardViewModel` und stellt
/// dessen aufbereitete Daten dar. Aktuell werden Mockdaten genutzt.
struct DashboardView: View {

    @Environment(\.dependencies) private var dependencies
    @State private var viewModel: DashboardViewModel?
    @State private var isShowingRelapse = false

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    content(for: viewModel)
                } else {
                    ProgressView("Lädt…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Übersicht")
            .background(Color(.systemGroupedBackground))
        }
        .task {
            if viewModel == nil {
                viewModel = DashboardViewModel(repository: dependencies.makeRecoveryRepository())
            }
            await viewModel?.onAppear()
        }
    }

    @ViewBuilder
    private func content(for viewModel: DashboardViewModel) -> some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView("Lädt…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case let .loaded(data):
                loadedContent(for: data, viewModel: viewModel)

            case .failed:
                ContentUnavailableView(
                    "Etwas ist schiefgelaufen",
                    systemImage: "exclamationmark.triangle",
                    description: Text("Bitte versuche es erneut.")
                )
            }
        }
        .sheet(isPresented: Binding(
            get: { viewModel.isShowingCravingHelp },
            set: { viewModel.isShowingCravingHelp = $0 }
        )) {
            CravingHelpView(onDismiss: { viewModel.isShowingCravingHelp = false })
        }
        .sheet(isPresented: $isShowingRelapse) {
            RelapseView(onSaved: {
                Task { await viewModel.load() }
            })
        }
    }

    private func loadedContent(for data: DashboardData, viewModel: DashboardViewModel) -> some View {
        ScrollView {
            VStack(spacing: AppSpacing.m) {
                StreakCardView(streak: data.streak)
                MotivationCardView(quote: data.quote)
                CravingButton(action: viewModel.handleCravingTapped)
                ProgressCardView(
                    progress: data.progress,
                    formattedMoneySaved: viewModel.formattedMoneySaved(for: data.progress)
                )
                DailyGoalCardView(goal: data.dailyGoal)

                RelapseButton(action: { isShowingRelapse = true })
            }
            .padding(AppSpacing.m)
        }
    }
}

#Preview {
    DashboardView()
}
