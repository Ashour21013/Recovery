import SwiftUI

/// Dashboard-Karte, die den Fortschritt zum gewählten Ziel anzeigt –
/// oder zum Festlegen eines Ziels auffordert. Reine UI-Komponente.
struct GoalCardView: View {
    let goalProgress: GoalProgress?
    let onSelectGoal: () -> Void

    var body: some View {
        CardContainer {
            if let goalProgress {
                activeGoal(goalProgress)
            } else {
                noGoal
            }
        }
    }

    // MARK: - Aktives Ziel

    private func activeGoal(_ progress: GoalProgress) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.m) {
            HStack {
                Label("Mein Ziel", systemImage: progress.goal.systemImage)
                    .font(AppFont.headline)
                Spacer()
                Button("Ändern", action: onSelectGoal)
                    .font(AppFont.subheadline)
            }

            HStack(alignment: .firstTextBaseline, spacing: AppSpacing.xs) {
                Text("\(progress.currentDays)")
                    .font(AppFont.roundedNumber(relativeTo: .title))
                    .foregroundStyle(AppColor.accent)
                Text("/ \(progress.goal.days) Tage")
                    .font(AppFont.subheadline)
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: progress.fraction)
                .tint(AppColor.accent)

            if progress.isAchieved {
                Label("Ziel erreicht! 🎉", systemImage: "checkmark.seal.fill")
                    .font(AppFont.subheadline.weight(.semibold))
                    .foregroundStyle(.green)
            } else {
                Text("Noch \(progress.remainingDays) Tage bis zum Ziel")
                    .font(AppFont.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Kein Ziel gesetzt

    private var noGoal: some View {
        VStack(alignment: .leading, spacing: AppSpacing.s) {
            Label("Ziel setzen", systemImage: "target")
                .font(AppFont.headline)
            Text("Wähle ein Ziel und verfolge deinen Fortschritt.")
                .font(AppFont.subheadline)
                .foregroundStyle(.secondary)
            Button(action: onSelectGoal) {
                Text("Ziel festlegen")
                    .font(AppFont.subheadline.weight(.semibold))
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, AppSpacing.xs)
        }
    }
}

#Preview {
    VStack {
        GoalCardView(
            goalProgress: GoalProgress(goal: .month, currentDays: 12),
            onSelectGoal: {}
        )
        GoalCardView(goalProgress: nil, onSelectGoal: {})
    }
    .padding()
}
