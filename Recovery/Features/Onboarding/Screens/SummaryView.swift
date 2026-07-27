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
                            OnboardingIllustration(emoji: habit.emoji, tint: AppColor.accent)
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
                PrimaryButton(title: "Meine Reise beginnen") {
                    withAnimation(.smooth(duration: 0.4)) { isFinishing = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                        onFinish()
                    }
                }
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
                .foregroundStyle(AppColor.accent)
                .frame(width: 32)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(AppFont.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(AppFont.body.weight(.semibold))
            }
            Spacer()
        }
        .padding(AppSpacing.m)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppColor.cardBackground)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(value)")
    }

    private var reasonCard: some View {
        HStack(spacing: AppSpacing.m) {
            Image(systemName: "quote.opening")
                .font(.title3)
                .foregroundStyle(AppColor.accent)
                .frame(width: 32)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text("Dein Warum")
                    .font(AppFont.caption)
                    .foregroundStyle(.secondary)
                Text(draft.reason.isEmpty ? "–" : draft.reason)
                    .font(AppFont.body.weight(.medium))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Spacer(minLength: 0)
        }
        .padding(AppSpacing.m)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppColor.cardBackground)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Dein Warum: \(draft.reason.isEmpty ? "nicht angegeben" : draft.reason)")
    }

    /// Kurze Erfolgs-Animation als Übergang zum Dashboard.
    private var completionOverlay: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: AppSpacing.l) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 88))
                    .foregroundStyle(AppColor.accent.gradient)
                    .symbolEffect(.bounce, value: isFinishing)
                    .accessibilityHidden(true)
                Text("Los geht's!")
                    .font(AppFont.title)
                Text("Dein erster cleaner Tag beginnt jetzt.")
                    .font(AppFont.body)
                    .foregroundStyle(.secondary)
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
