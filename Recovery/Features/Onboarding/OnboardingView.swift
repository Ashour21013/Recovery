import SwiftUI

/// Container des Onboarding-Flows.
///
/// Besitzt das `OnboardingViewModel` und verdrahtet die einzelnen Screens
/// über einen `NavigationStack`. Screen 1 (Welcome) ist die Wurzel,
/// die weiteren Schritte werden über den Navigationspfad des ViewModels
/// gesteuert. Die Screens selbst kennen die Navigation nicht – sie melden
/// nur Aktionen an das ViewModel (Trennung von Logik und UI).
struct OnboardingView: View {

    @Environment(\.dependencies) private var dependencies
    @State private var viewModel: OnboardingViewModel?

    /// Wird aufgerufen, sobald das Onboarding abgeschlossen ist.
    let onComplete: () -> Void

    var body: some View {
        Group {
            if let viewModel {
                NavigationStack(path: Binding(
                    get: { viewModel.path },
                    set: { viewModel.path = $0 }
                )) {
                    WelcomeView(onContinue: viewModel.start)
                        .navigationDestination(for: OnboardingStep.self) { step in
                            destination(for: step, viewModel: viewModel)
                        }
                }
            } else {
                ProgressView()
            }
        }
        .task {
            if viewModel == nil {
                viewModel = OnboardingViewModel(repository: dependencies.makeRecoveryRepository())
            }
        }
    }

    @ViewBuilder
    private func destination(for step: OnboardingStep, viewModel: OnboardingViewModel) -> some View {
        switch step {
        case .habitSelection:
            HabitSelectionView(
                selected: viewModel.draft.habitType,
                onSelect: viewModel.selectHabit,
                canContinue: viewModel.canContinueFromHabitSelection,
                onContinue: viewModel.goToReason
            )

        case .reason:
            ReasonView(
                reason: Binding(
                    get: { viewModel.draft.reason },
                    set: viewModel.updateReason
                ),
                onContinue: viewModel.goToFrequency
            )

        case .frequency:
            FrequencyView(
                selected: viewModel.draft.frequency,
                onSelect: viewModel.selectFrequency,
                canContinue: viewModel.canContinueFromFrequency,
                onContinue: viewModel.goToSummary
            )

        case .summary:
            SummaryView(
                draft: viewModel.draft,
                onFinish: {
                    Task {
                        if await viewModel.finish() {
                            onComplete()
                        }
                    }
                }
            )
        }
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
