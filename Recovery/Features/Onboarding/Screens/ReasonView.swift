import SwiftUI

/// Screen 3 – Grund, warum der Nutzer aufhören möchte.
///
/// Persönliche Ansprache mit Illustration und optionalen Vorschlägen, die den
/// Einstieg erleichtern. Reine UI-Komponente.
struct ReasonView: View {
    @Binding var reason: String
    let onContinue: () -> Void

    private let suggestions = [
        String(localized: "Für meine Gesundheit"),
        String(localized: "Für meine Familie"),
        String(localized: "Um Geld zu sparen"),
        String(localized: "Um mich freier zu fühlen"),
        String(localized: "Für mehr Selbstachtung")
    ]

    var body: some View {
        OnboardingScaffold(
            step: .reason,
            title: String(localized: "Was ist dein Warum?"),
            subtitle: String(localized: "Deine persönliche Motivation gibt dir Kraft in schwierigen Momenten.")
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.m) {
                HStack {
                    Spacer()
                    OnboardingIllustration(systemImage: "target", tint: AppColor.coral)
                        .scaleEffect(0.8)
                    Spacer()
                }

                AppTextEditor(placeholder: String(localized: "Ich möchte aufhören, weil…"), text: $reason)

                Text("Vorschläge")
                    .font(AppFont.caption.weight(.semibold))
                    .foregroundStyle(AppColor.muted)

                FlowLayout(spacing: AppSpacing.s) {
                    ForEach(suggestions, id: \.self) { suggestion in
                        SelectableChip(
                            title: suggestion,
                            isSelected: reason == suggestion,
                            action: { withAnimation(.smooth) { reason = suggestion } }
                        )
                    }
                }
            }
        } footer: {
            Button(action: onContinue) { Text("Weiter") }
                .buttonStyle(GradientCTAButtonStyle())
        }
    }
}

#Preview {
    NavigationStack {
        ReasonView(reason: .constant(""), onContinue: {})
    }
}
