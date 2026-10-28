import SwiftUI

/// Craving-Modus im Figma-Design: dunkler, ruhiger Vollbild-Flow mit
/// Schritt-Segmenten oben und großem hellen „Weiter“-Button unten.
/// Ablauf-Logik liegt im `CravingModeViewModel`.
struct CravingModeView: View {

    @Environment(\.dependencies) private var dependencies
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: CravingModeViewModel?
    @State private var isShowingHelp = false

    var body: some View {
        ZStack {
            RadialGradient(colors: [Color(hex: 0x215B57), Color(hex: 0x0D292A)],
                           center: UnitPoint(x: 0.5, y: 0.4), startRadius: 0, endRadius: 520)
                .ignoresSafeArea()

            if let viewModel {
                VStack(spacing: 0) {
                    header(viewModel)
                    stepContent(viewModel)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .id(viewModel.currentIndex)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    footer(viewModel)
                }
                .padding(.horizontal, 22)
                .padding(.top, 8)
                .padding(.bottom, 16)
                .animation(.smooth(duration: 0.35), value: viewModel.currentIndex)
            } else {
                ProgressView().tint(.white)
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $isShowingHelp) { HelpView() }
        .task {
            if viewModel == nil {
                viewModel = CravingModeViewModel(repository: dependencies.makeRecoveryRepository())
            }
            await viewModel?.onAppear()
        }
    }

    private func header(_ viewModel: CravingModeViewModel) -> some View {
        let total = CravingStep.allCases.count
        return VStack(spacing: 17) {
            HStack {
                glassCircleButton("xmark", label: String(localized: "Schließen")) { dismiss() }
                Spacer()
                Text("\(viewModel.currentIndex + 1) von \(total)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.65))
                Spacer()
                glassCircleButton("lifepreserver", label: String(localized: "Hilfe & Ressourcen")) { isShowingHelp = true }
            }
            HStack(spacing: 5) {
                ForEach(0..<total, id: \.self) { index in
                    Capsule()
                        .fill(index <= viewModel.currentIndex ? Color(hex: 0x79C9B9) : .white.opacity(0.15))
                        .frame(height: 3)
                }
            }
            .animation(.smooth, value: viewModel.currentIndex)
        }
    }

    private func glassCircleButton(_ icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(Circle().fill(.white.opacity(0.1)))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    @ViewBuilder
    private func stepContent(_ viewModel: CravingModeViewModel) -> some View {
        switch viewModel.currentStep {
        case .welcome:
            CravingMessageStepView(
                systemImage: "leaf.fill",
                title: String(localized: "Du schaffst das."),
                message: String(localized: "Lass uns diesen Moment gemeinsam durchstehen. Nur ein Schritt nach dem anderen.")
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
                systemImage: "water.waves",
                eyebrow: String(localized: "ERINNERE DICH"),
                title: String(localized: "Es ist nur eine Welle."),
                message: String(localized: "Das Verlangen kommt, erreicht seinen Höhepunkt – und geht wieder vorbei.")
            )
        case .affirmation:
            CravingMessageStepView(
                systemImage: "sparkles",
                eyebrow: String(localized: "SPRICH ES LAUT AUS"),
                title: String(localized: "Ich bin stärker als dieser Moment."),
                message: String(localized: "Du musst dem Gedanken nicht folgen.")
            ) {
                CravingQuoteBox(text: viewModel.affirmation.text)
            }
        case .reason:
            CravingMessageStepView(
                systemImage: "heart.fill",
                eyebrow: String(localized: "DEIN WARUM"),
                title: String(localized: "Darum machst du das."),
                message: viewModel.reason.isEmpty
                    ? String(localized: "Erinnere dich an den Grund, warum du diese Reise begonnen hast.")
                    : String(localized: "Erinnere dich an deinen persönlichen Grund:")
            ) {
                if !viewModel.reason.isEmpty {
                    CravingQuoteBox(text: viewModel.reason)
                }
            }
        case .task:
            CravingMessageStepView(
                systemImage: viewModel.task.systemImage,
                eyebrow: String(localized: "EINE KLEINE AUFGABE"),
                title: viewModel.task.title,
                message: String(localized: "Lenke Körper und Kopf für ein paar Minuten ab.")
            )
        case .finish:
            CravingMessageStepView(
                systemImage: "checkmark",
                eyebrow: String(localized: "GESCHAFFT"),
                title: String(localized: "Verlangen überstanden!"),
                message: String(localized: "Stark. Du hast dich heute für dich entschieden. Das zählt."),
                isSuccess: true
            )
        }
    }

    private func footer(_ viewModel: CravingModeViewModel) -> some View {
        HStack(spacing: 10) {
            if !viewModel.isFirstStep {
                Button(action: viewModel.goBack) {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.bold))
                        .frame(width: 54, height: 54)
                        .background(RoundedRectangle(cornerRadius: 17, style: .continuous).fill(.white.opacity(0.1)))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .accessibilityLabel("Zurück")
                .transition(.move(edge: .leading).combined(with: .opacity))
            }
            Button {
                if viewModel.isLastStep {
                    dependencies.cravingSessionCounter.incrementCompleted()
                    dismiss()
                } else {
                    viewModel.goNext()
                }
            } label: {
                HStack(spacing: 7) {
                    Text(viewModel.isLastStep ? String(localized: "Zurück zu Heute") : String(localized: "Weiter"))
                    if !viewModel.isLastStep { Image(systemName: "chevron.right") }
                }
                .font(.body.weight(.bold))
                .foregroundStyle(Color(hex: 0x155D57))
                .frame(maxWidth: .infinity, minHeight: 54)
                .background(RoundedRectangle(cornerRadius: 17, style: .continuous).fill(Color(hex: 0xF4FCF9)))
            }
            .buttonStyle(PressScaleStyle())
        }
        .animation(.smooth, value: viewModel.isFirstStep)
    }
}

/// Dezentes Press-Feedback ohne eigene Hintergrundfarbe.
struct PressScaleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.smooth(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    CravingModeView()
}
