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
    @State private var isShowingHelp = false

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
            .toolbar {
                if let viewModel, !viewModel.addictions.isEmpty {
                    ToolbarItem(placement: .principal) {
                        AddictionSwitcherMenu(
                            addictions: viewModel.addictions,
                            onSwitch: { id in Task { await viewModel.switchAddiction(to: id) } },
                            onManage: viewModel.presentAddictionManager
                        )
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isShowingHelp = true
                    } label: {
                        Image(systemName: "lifepreserver")
                    }
                    .accessibilityLabel("Hilfe & Ressourcen")
                }
            }
            .sheet(isPresented: $isShowingHelp) {
                HelpView()
            }
            .sheet(isPresented: Binding(
                get: { viewModel?.isShowingAddictionManager ?? false },
                set: { viewModel?.isShowingAddictionManager = $0 }
            )) {
                AddictionManagerView(onChange: {
                    Task { await viewModel?.addictionsDidChange() }
                })
            }
        }
        .task {
            if viewModel == nil {
                viewModel = DashboardViewModel(
                    repository: dependencies.makeRecoveryRepository(),
                    motivationService: dependencies.motivationService,
                    savingsFactory: dependencies.savingsMetricProviderFactory
                )
            }
            await viewModel?.onAppear()
            await updateWidgetSnapshot()
        }
    }

    /// Aktualisiert den geteilten Widget-Snapshot aus dem aktuellen Profil.
    /// Reine Datenweitergabe an die App Group – keine UI-Logik.
    private func updateWidgetSnapshot() async {
        let loaded = try? await dependencies.makeRecoveryRepository().loadProfile()
        if let profile = loaded ?? nil {
            dependencies.refreshWidgetSnapshot(profile: profile)
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
        .sheet(isPresented: Binding(
            get: { viewModel.isShowingPlanEditor },
            set: { viewModel.isShowingPlanEditor = $0 }
        )) {
            PlanEditorView(onChange: {
                Task { await viewModel.planDidChange() }
            })
        }
        .sheet(isPresented: Binding(
            get: { viewModel.isShowingMetricsEditor },
            set: { viewModel.isShowingMetricsEditor = $0 }
        )) {
            MetricsEditorView(onSaved: {
                Task { await viewModel.metricsDidChange() }
            })
        }
        .sheet(isPresented: Binding(
            get: { viewModel.isShowingSourcePicker },
            set: { viewModel.isShowingSourcePicker = $0 }
        )) {
            MotivationSourcePickerView(
                current: viewModel.motivationSource,
                onSelect: { source in Task { await viewModel.setMotivationSource(source) } },
                onCancel: { viewModel.isShowingSourcePicker = false }
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
                MotivationCardView(
                    motivation: data.motivation,
                    onChangeSource: viewModel.presentSourcePicker
                )
                CravingButton(action: viewModel.handleCravingTapped)
                GoalCardView(
                    goalProgress: data.goalProgress,
                    onSelectGoal: viewModel.presentGoalPicker
                )
                RecoveryGainsSectionView(
                    gains: viewModel.gains,
                    hasMetrics: viewModel.hasMetrics,
                    onAddValues: viewModel.presentMetricsEditor
                )
                .premiumGated(.recoveryGains) {
                    SampleMetricsPreview()
                }
                ProgressCardView(
                    progress: data.progress
                )
                RecoveryPlanCardView(
                    plan: data.plan,
                    onToggle: { taskId in Task { await viewModel.toggleTask(taskId) } },
                    onEdit: viewModel.presentPlanEditor
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
