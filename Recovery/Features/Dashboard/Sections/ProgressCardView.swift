import SwiftUI

/// Fortschrittskarte: Meilenstein-Fortschritt und Kennzahlen.
/// Reine UI-Komponente – erhält bereits aufbereitete Werte.
struct ProgressCardView: View {
    let progress: ProgressSummary
    let formattedMoneySaved: String

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

                Divider()

                HStack(spacing: AppSpacing.m) {
                    metric(
                        value: formattedMoneySaved,
                        label: "Gespart",
                        systemImage: "eurosign.circle.fill"
                    )
                    Divider().frame(height: 40)
                    metric(
                        value: "\(progress.avoidedCount)",
                        label: "Vermieden",
                        systemImage: "shield.lefthalf.filled"
                    )
                }
            }
        }
    }

    private func metric(value: String, label: String, systemImage: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Label(value, systemImage: systemImage)
                .font(.title3.weight(.semibold))
                .labelStyle(.titleAndIcon)
            Text(label)
                .font(AppFont.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(value)")
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
        ),
        formattedMoneySaved: "84,00 €"
    )
    .padding()
}
