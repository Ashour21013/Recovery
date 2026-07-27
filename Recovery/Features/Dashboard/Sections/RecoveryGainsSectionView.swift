import SwiftUI

/// Dashboard-Sektion, die die Fortschritts-Gewinne der aktiven Sucht zeigt.
///
/// Stellt entweder die berechneten `RecoveryGain`-Karten dar oder – falls
/// keine Eingaben vorliegen – einen dezenten Hinweis "Werte hinzufügen".
struct RecoveryGainsSectionView: View {
    let gains: [RecoveryGain]
    let hasMetrics: Bool
    let onAddValues: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.s) {
            header

            if gains.isEmpty {
                emptyHint
            } else {
                ForEach(gains) { gain in
                    RecoveryGainCard(gain: gain)
                }
            }
        }
    }

    private var header: some View {
        HStack {
            Text("Was du gewinnst")
                .font(AppFont.headline)
            Spacer()
            if hasMetrics {
                Button("Anpassen", action: onAddValues)
                    .font(AppFont.subheadline)
            }
        }
    }

    private var emptyHint: some View {
        Button(action: onAddValues) {
            HStack(spacing: AppSpacing.m) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(AppColor.accent)
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Werte hinzufügen")
                        .font(AppFont.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text("Hinterlege deine Angaben, um deinen echten Gewinn zu sehen.")
                        .font(AppFont.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 0)
            }
            .padding(AppSpacing.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColor.cardBackground, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityHint("Öffnet die Eingabe deiner Werte")
    }
}

#Preview {
    VStack(spacing: AppSpacing.m) {
        RecoveryGainsSectionView(gains: [], hasMetrics: false, onAddValues: {})
        RecoveryGainsSectionView(
            gains: [
                RecoveryGain(
                    id: "1", kind: .money, value: 84, unit: "EUR",
                    title: "Gespart", detail: "Etwa 210,00 € pro Monat",
                    systemImage: "eurosign.circle.fill"
                )
            ],
            hasMetrics: true,
            onAddValues: {}
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
