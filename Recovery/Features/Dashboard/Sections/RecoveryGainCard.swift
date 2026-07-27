import SwiftUI

/// Wiederverwendbare Karte, die einen `RecoveryGain` einheitlich darstellt –
/// unabhängig davon, ob es sich um Geld, Zeit oder Menge handelt.
///
/// Reine UI-Komponente: erhält bereits aufbereitete Domain-Werte und enthält
/// keine Geschäftslogik.
struct RecoveryGainCard: View {
    let gain: RecoveryGain

    var body: some View {
        HStack(spacing: AppSpacing.m) {
            iconBadge

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(gain.title)
                    .font(AppFont.footnote)
                    .foregroundStyle(.secondary)
                if gain.kind != .health {
                    Text(gain.formattedValue)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText())
                }
                Text(gain.detail)
                    .font(AppFont.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(AppSpacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.cardBackground, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        gain.kind == .health
            ? "\(gain.title). \(gain.detail)"
            : "\(gain.title): \(gain.formattedValue). \(gain.detail)"
    }

    private var iconBadge: some View {
        Image(systemName: gain.systemImage)
            .font(.title2)
            .foregroundStyle(tint)
            .frame(width: 44, height: 44)
            .background(tint.opacity(0.15), in: Circle())
    }

    private var tint: Color {
        switch gain.kind {
        case .money: return AppColor.success
        case .time: return AppColor.accent
        case .quantity: return AppColor.warning
        case .health: return .pink
        }
    }
}

#Preview {
    VStack(spacing: AppSpacing.m) {
        RecoveryGainCard(
            gain: RecoveryGain(
                id: "1", kind: .money, value: 84, unit: "EUR",
                title: "Gespart", detail: "Etwa 210,00 € pro Monat",
                systemImage: "eurosign.circle.fill"
            )
        )
        RecoveryGainCard(
            gain: RecoveryGain(
                id: "2", kind: .time, value: 36, unit: "Std.",
                title: "Zurückgewonnen", detail: "Entspricht ca. 4 Arbeitstagen",
                systemImage: "clock.arrow.circlepath"
            )
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
