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
                    .transition(.opacity)

            case let .loaded(data):
                loadedContent(for: data, viewModel: viewModel)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))

            case .failed:
                ContentUnavailableView(
                    "Etwas ist schiefgelaufen",
                    systemImage: "exclamationmark.triangle",
                    description: Text("Bitte versuche es erneut.")
                )
                .transition(.opacity)
            }
        }
        .animation(.smooth, value: viewModel.state)
        .sheet(isPresented: Binding(
            get: { viewModel.isShowingCravingHelp },
            set: { viewModel.isShowingCravingHelp = $0 }
        )) {
            CravingModeView()
        }
        .sheet(isPresented: $isShowingRelapse) {
            RelapseView(onSaved: {
                Task { await viewModel.load() }
            })
        }
        .sheet(isPresented: Binding(
            get: { viewModel.isShowingGoalPicker },
            set: { viewModel.isShowingGoalPicker = $0 }
        )) {
            GoalPickerView(
                currentGoal: currentGoal(viewModel),
                currentDays: currentDays(viewModel),
                onSelect: { goal in Task { await viewModel.setGoal(goal) } },
                onRemove: { Task { await viewModel.setGoal(nil) } },
                onCancel: { viewModel.isShowingGoalPicker = false }
            )
        }
        .alert(
            "Ziel erreicht! 🎉",
            isPresented: Binding(
                get: { viewModel.achievedGoal != nil },
                set: { if !$0 { viewModel.dismissAchievement() } }
            )
        ) {
            Button("Weiter so!", action: viewModel.dismissAchievement)
        } message: {
            if let goal = viewModel.achievedGoal {
                Text("Glückwunsch! Du hast dein Ziel von \(goal.title) erreicht. Bleib dran!")
            }
        }
    }

    // MARK: - Helpers für den Ziel-Picker

    private func currentGoal(_ viewModel: DashboardViewModel) -> RecoveryGoal? {
        if case let .loaded(data) = viewModel.state {
            return data.goalProgress?.goal
        }
        return nil
    }

    private func currentDays(_ viewModel: DashboardViewModel) -> Int {
        if case let .loaded(data) = viewModel.state {
            return data.streak.currentDays
        }
        return 0
    }

    private func loadedContent(for data: DashboardData, viewModel: DashboardViewModel) -> some View {
        ScrollView {
            VStack(spacing: AppSpacing.m) {
                StreakCardView(streak: data.streak)
                MotivationCardView(quote: data.quote)
                CravingButton(action: viewModel.handleCravingTapped)
                GoalCardView(
                    goalProgress: data.goalProgress,
                    onSelectGoal: viewModel.presentGoalPicker
                )
                ProgressCardView(
                    progress: data.progress,
                    formattedMoneySaved: viewModel.formattedMoneySaved(for: data.progress)
                )
                RecoveryPlanCardView(
                    plan: data.plan,
                    onToggle: { type in Task { await viewModel.toggleTask(type) } }
                )

                RelapseButton(action: { isShowingRelapse = true })
            }
            .padding(AppSpacing.m)
        }
    }
}

#Preview {
    DashboardView()
}
