import SwiftUI

/// Fortschrittskarte: Meilenstein-Fortschritt.
/// Reine UI-Komponente – erhält bereits aufbereitete Werte. Die konkreten
/// Kennzahlen (Geld/Zeit/Menge) zeigt die `RecoveryGainsSectionView`.
struct ProgressCardView: View {
    let progress: ProgressSummary

    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: AppSpacing.m) {
                Text("Dein Fortschritt")
                    .font(AppFont.headline)

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    HStack {
                        Text("Nächster Meilenstein")
                            .font(AppFont.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(progress.nextMilestoneTitle)
                            .font(AppFont.subheadline.weight(.semibold))
                    }
                    ProgressView(value: progress.clampedMilestoneFraction)
                        .tint(AppColor.accent)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Nächster Meilenstein: \(progress.nextMilestoneTitle)")
            }
        }
    }
}

#Preview {
    ProgressCardView(
        progress: ProgressSummary(
            milestoneFraction: 0.4,
            nextMilestoneTitle: "30 Tage",
            moneySaved: 84,
            currencyCode: "EUR",
            avoidedCount: 144
        )
    )
    .padding()
}
