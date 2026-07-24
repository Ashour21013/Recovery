import SwiftUI

/// Screen 3 – Grund, warum der Nutzer aufhören möchte.
///
/// Persönliche Ansprache mit Illustration und optionalen Vorschlägen, die den
/// Einstieg erleichtern. Reine UI-Komponente.
struct ReasonView: View {
    @Binding var reason: String
    let onContinue: () -> Void

    private let suggestions = [
        "Für meine Gesundheit",
        "Für meine Familie",
        "Um Geld zu sparen",
        "Um mich freier zu fühlen",
        "Für mehr Selbstachtung"
    ]

    var body: some View {
        OnboardingScaffold(
            step: .reason,
            title: "Was ist dein Warum?",
            subtitle: "Deine persönliche Motivation gibt dir Kraft in schwierigen Momenten."
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.m) {
                HStack {
                    Spacer()
                    OnboardingIllustration(systemImage: "target", tint: .pink)
                        .scaleEffect(0.8)
                    Spacer()
                }

                AppTextEditor(placeholder: "Ich möchte aufhören, weil…", text: $reason)

                Text("Vorschläge")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

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
            PrimaryButton(title: "Weiter", action: onContinue)
        }
    }
}

#Preview {
    NavigationStack {
        ReasonView(reason: .constant(""), onContinue: {})
    }
}
