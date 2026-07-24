import SwiftUI

/// Craving-Modus: führt den Nutzer Schritt für Schritt durch einen kurzen
/// Notfallplan. Der Ablauf ist über `CravingStep` modular erweiterbar.
///
/// Die View bindet an das `CravingModeViewModel` (MVVM) und enthält keine
/// Ablauf- oder Persistenzlogik.
struct CravingModeView: View {

    @Environment(\.dependencies) private var dependencies
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: CravingModeViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    VStack(spacing: 0) {
                        ProgressView(value: viewModel.progress)
                            .tint(AppColor.accent)
                            .padding(.horizontal, AppSpacing.l)
                            .padding(.top, AppSpacing.s)

                        stepContent(viewModel)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .transition(.opacity)

                        footer(viewModel)
                    }
                    .animation(.default, value: viewModel.currentIndex)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle(viewModel?.currentStep.title ?? "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Schließen") { dismiss() }
                }
            }
        }
        .task {
            if viewModel == nil {
                viewModel = CravingModeViewModel(repository: dependencies.makeRecoveryRepository())
            }
            await viewModel?.onAppear()
        }
    }

    // MARK: - Schritt-Inhalt

    @ViewBuilder
    private func stepContent(_ viewModel: CravingModeViewModel) -> some View {
        switch viewModel.currentStep {
        case .welcome:
            CravingMessageStepView(
                systemImage: "hand.raised.fill",
                title: "Kurz innehalten",
                message: "Das Verlangen ist nur eine Welle – sie kommt und geht. Wir gehen das jetzt gemeinsam in wenigen Schritten durch."
            )

        case .breathing:
            BreathingStepView(
                remainingSeconds: viewModel.remainingSeconds,
                progress: viewModel.breathingProgress,
                isRunning: viewModel.isBreathingRunning,
                onStart: viewModel.startBreathing
            )

        case .motivation:
            CravingMessageStepView(
                systemImage: "bolt.heart.fill",
                title: "Du bist stärker",
                message: "Jedes Mal, wenn du dem Verlangen widerstehst, wird es schwächer. Du baust gerade echte Stärke auf.",
                tint: .pink
            )

        case .affirmation:
            CravingMessageStepView(
                systemImage: "quote.bubble.fill",
                title: "Sprich es dir laut vor",
                message: "Lies diese Affirmation laut und langsam vor:",
                tint: .purple
            ) {
                Text("„\(viewModel.affirmation.text)")
                    .font(.title3.weight(.medium))
                    .multilineTextAlignment(.center)
                    .padding(AppSpacing.l)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.secondarySystemBackground))
                    )
            }

        case .reason:
            CravingMessageStepView(
                systemImage: "target",
                title: "Warum du aufhören möchtest",
                message: reasonMessage(viewModel.reason)
            ) {
                if !viewModel.reason.isEmpty {
                    Text("„\(viewModel.reason)")
                        .font(.title3.weight(.medium))
                        .multilineTextAlignment(.center)
                        .padding(AppSpacing.l)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.secondarySystemBackground))
                        )
                }
            }

        case .task:
            CravingMessageStepView(
                systemImage: viewModel.task.systemImage,
                title: "Kleine Aufgabe",
                message: "Lenke deinen Körper und Kopf ab. Versuch jetzt:",
                tint: .orange
            ) {
                Text(viewModel.task.title)
                    .font(.title2.weight(.bold))
                    .padding(.top, AppSpacing.s)
            }

        case .finish:
            CravingMessageStepView(
                systemImage: "checkmark.seal.fill",
                title: "Geschafft!",
                message: "Du hast die Welle überstanden, ohne rückfällig zu werden. Sei stolz auf dich.",
                tint: .green
            )
        }
    }

    // MARK: - Footer-Navigation

    @ViewBuilder
    private func footer(_ viewModel: CravingModeViewModel) -> some View {
        HStack(spacing: AppSpacing.m) {
            if !viewModel.isFirstStep {
                Button(action: viewModel.goBack) {
                    Text("Zurück")
                        .frame(maxWidth: .infinity)
                        .padding(AppSpacing.m)
                }
                .buttonStyle(.bordered)
            }

            if viewModel.isLastStep {
                PrimaryButton(title: "Abschließen") {
                    dependencies.cravingSessionCounter.incrementCompleted()
                    dismiss()
                }
            } else {
                PrimaryButton(title: "Weiter", action: viewModel.goNext)
            }
        }
        .padding(AppSpacing.l)
    }

    private func reasonMessage(_ reason: String) -> String {
        reason.isEmpty
        ? "Erinnere dich an den Grund, warum du diese Reise begonnen hast."
        : "Erinnere dich an deinen persönlichen Grund:"
    }
}

#Preview {
    CravingModeView()
}
