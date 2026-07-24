import SwiftUI

/// Einheitliches Layout-Gerüst für die inhaltlichen Onboarding-Schritte.
///
/// Bündelt Progress-Bar, Titel/Untertitel, den scrollbaren Inhalt und einen
/// festen Footer (z. B. „Weiter"-Button). Blendet Kopf und Inhalt beim
/// Erscheinen dezent gestaffelt ein. Reine, wiederverwendbare UI-Komponente.
struct OnboardingScaffold<Content: View, Footer: View>: View {
    let step: OnboardingStep
    let title: String
    var subtitle: String? = nil
    @ViewBuilder var content: () -> Content
    @ViewBuilder var footer: () -> Footer

    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.l) {
            OnboardingProgressBar(currentStep: step.index, totalSteps: OnboardingStep.total)
                .padding(.top, AppSpacing.s)

            VStack(alignment: .leading, spacing: AppSpacing.s) {
                Text(title)
                    .font(AppFont.title)
                    .fixedSize(horizontal: false, vertical: true)

                if let subtitle {
                    Text(subtitle)
                        .font(AppFont.body)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)

            content()
                .frame(maxWidth: .infinity, alignment: .leading)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)

            Spacer(minLength: 0)

            footer()
        }
        .padding(AppSpacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .navigationBarTitleDisplayMode(.inline)
        .animation(.smooth(duration: 0.5), value: appeared)
        .onAppear { appeared = true }
    }
}
