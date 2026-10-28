import SwiftUI

/// Screen 5 – Zusammenfassung der erfassten Eingaben.
///
/// Fasst die Auswahl hochwertig zusammen und leitet mit einer kurzen
/// Erfolgs-Animation zum Dashboard über. Reine UI-Komponente.
struct SummaryView: View {
    let draft: OnboardingDraft
    let onFinish: () -> Void

    @State private var isFinishing = false

    var body: some View {
        ZStack {
            OnboardingScaffold(
                step: .summary,
                title: "Bereit für den Neustart?",
                subtitle: "Hier ist dein persönlicher Plan. Du kannst alles später anpassen."
            ) {
                VStack(spacing: AppSpacing.m) {
                    if let habit = draft.habitType {
                        HStack {
                            Spacer()
                            OnboardingIllustration(emoji: habit.emoji, tint: AppColor.teal)
                                .scaleEffect(0.8)
                            Spacer()
                        }
                    }

                    summaryCard(
                        icon: "flag.checkered",
                        label: "Gewohnheit",
                        value: draft.habitType?.title ?? "–"
                    )
                    summaryCard(
                        icon: "clock.arrow.circlepath",
                        label: "Häufigkeit",
                        value: draft.frequency?.title ?? "–"
                    )
                    reasonCard
                }
            } footer: {
                Button {
                    withAnimation(.smooth(duration: 0.4)) { isFinishing = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                        onFinish()
                    }
                } label: {
                    Text("Meine Reise beginnen")
                }
                .buttonStyle(GradientCTAButtonStyle())
            }

            if isFinishing {
                completionOverlay
                    .transition(.opacity)
            }
        }
    }

    // MARK: - Bausteine

    private func summaryCard(icon: String, label: String, value: String) -> some View {
        HStack(spacing: AppSpacing.m) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(AppColor.teal)
                .frame(width: 32)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.muted)
                Text(value)
                    .font(AppFont.body.weight(.semibold))
            }
            Spacer()
        }
        .figmaCard(radius: 18, padding: AppSpacing.m)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(value)")
    }

    private var reasonCard: some View {
        HStack(spacing: AppSpacing.m) {
            Image(systemName: "quote.opening")
                .font(.title3)
                .foregroundStyle(AppColor.teal)
                .frame(width: 32)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text("Dein Warum")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.muted)
                Text(draft.reason.isEmpty ? "–" : draft.reason)
                    .font(AppFont.body.weight(.medium))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Spacer(minLength: 0)
        }
        .figmaCard(radius: 18, padding: AppSpacing.m)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Dein Warum: \(draft.reason.isEmpty ? "nicht angegeben" : draft.reason)")
    }

    /// Kurze Erfolgs-Animation als Übergang zum Dashboard.
    private var completionOverlay: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()
            VStack(spacing: AppSpacing.l) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 88))
                    .foregroundStyle(AppColor.teal.gradient)
                    .symbolEffect(.bounce, value: isFinishing)
                    .accessibilityHidden(true)
                Text("Los geht's!")
                    .font(AppFont.title)
                Text("Dein erster cleaner Tag beginnt jetzt.")
                    .font(AppFont.body)
                    .foregroundStyle(AppColor.muted)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SummaryView(
            draft: OnboardingDraft(habitType: .smoking, reason: "Für meine Gesundheit.", frequency: .daily),
            onFinish: {}
        )
    }
}
