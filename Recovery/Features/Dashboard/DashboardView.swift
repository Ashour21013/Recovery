import SwiftUI

/// Dashboard-Screen der App.
///
/// Setzt die einzelnen Sektionen (Streak, Motivation, Cravings-Button,
/// Fortschritt, Tagesziel) zusammen. Die View enthält keine
/// Geschäftslogik – sie bindet an das `DashboardViewModel` und stellt
/// dessen aufbereitete Daten dar. Aktuell werden Mockdaten genutzt.
struct DashboardView: View {

    @State private var viewModel = DashboardViewModel()

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle, .loading:
                    ProgressView("Lädt…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                case let .loaded(data):
                    content(for: data)

                case .failed:
                    ContentUnavailableView(
                        "Etwas ist schiefgelaufen",
                        systemImage: "exclamationmark.triangle",
                        description: Text("Bitte versuche es erneut.")
                    )
                }
            }
            .navigationTitle("Übersicht")
            .background(Color(.systemGroupedBackground))
        }
        .sheet(isPresented: $viewModel.isShowingCravingHelp) {
            CravingHelpView(onDismiss: { viewModel.isShowingCravingHelp = false })
        }
        .onAppear(perform: viewModel.onAppear)
    }

    private func content(for data: DashboardData) -> some View {
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
            }
            .padding(AppSpacing.m)
        }
    }
}

#Preview {
    DashboardView()
}
