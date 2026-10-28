import SwiftUI

/// „Recovery Gains“ im Figma-Stil: 3er-Raster mit farbigen Icon-Kacheln.
/// Welche Werte erscheinen, hängt vom aktiven Modus ab (z. B. bei
/// Pornografie Zeit statt Geld) – das liefern die SavingsMetricProvider.
struct RecoveryGainsSectionView: View {
    let gains: [RecoveryGain]
    let hasMetrics: Bool
    let onAddValues: () -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

    private var valueGains: [RecoveryGain] { gains.filter { $0.kind != .health } }
    private var healthGains: [RecoveryGain] { gains.filter { $0.kind == .health } }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            header

            if gains.isEmpty {
                emptyHint
            } else {
                if !valueGains.isEmpty {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(Array(valueGains.prefix(6).enumerated()), id: \.element.id) { index, gain in
                            RecoveryGainCard(gain: gain, tone: GainTone.forIndex(index))
                        }
                    }
                }
                ForEach(healthGains) { gain in
                    RecoveryHealthRow(gain: gain)
                }
            }
        }
        .padding(.top, 13)
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("RECOVERY GAINS")
                    .font(.caption2.weight(.heavy))
                    .tracking(1.35)
                    .foregroundStyle(AppColor.muted)
                Text("Was du zurückgewinnst")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(AppColor.ink)
            }
            Spacer()
            Button(action: onAddValues) {
                Text(hasMetrics ? "Berechnung" : "Werte angeben")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(AppColor.teal)
                    .padding(.horizontal, 10)
                    .frame(minHeight: 34)
                    .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(AppColor.mint))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 2)
    }

    private var emptyHint: some View {
        Button(action: onAddValues) {
            HStack(spacing: 11) {
                Image(systemName: "sparkles")
                    .foregroundStyle(AppColor.teal)
                    .frame(width: 36, height: 36)
                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(AppColor.mint))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Werte hinzufügen")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColor.ink)
                    Text("Die Werte sind persönliche Hochrechnungen aus deinen Angaben.")
                        .font(.caption)
                        .foregroundStyle(AppColor.muted)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 0)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .gainSurface(radius: 18)
        }
        .buttonStyle(.plain)
        .accessibilityHint("Öffnet die Eingabe deiner Werte")
    }
}

/// Farbtöne der Gain-Kacheln wie im Figma (mint, blau, coral).
enum GainTone {
    case mint, blue, coral

    static func forIndex(_ index: Int) -> GainTone { [.mint, .blue, .coral][index % 3] }

    var foreground: Color {
        switch self {
        case .mint: AppColor.teal
        case .blue: Color(hex: 0x4F81AA)
        case .coral: AppColor.coral
        }
    }

    var background: Color {
        switch self {
        case .mint: AppColor.mint
        case .blue: Color(light: 0xE5F0FA, dark: 0x1E3346)
        case .coral: AppColor.coralSoft
        }
    }
}

extension View {
    func gainSurface(radius: CGFloat) -> some View {
        background(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(AppColor.surface)
                .shadow(color: Color(hex: 0x1C433E, opacity: 0.05), radius: 9, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .stroke(AppColor.line.opacity(0.7), lineWidth: 1)
        )
    }
}

#Preview {
    RecoveryGainsSectionView(
        gains: [
            RecoveryGain(id: "1", kind: .money, value: 84, unit: "EUR", title: "Geld gespart", detail: "", systemImage: "wallet.bifold"),
            RecoveryGain(id: "2", kind: .quantity, value: 60, unit: "", title: "Zigaretten vermieden", detail: "", systemImage: "shield"),
            RecoveryGain(id: "3", kind: .time, value: 6, unit: "Std", title: "Pausen gewonnen", detail: "", systemImage: "clock")
        ],
        hasMetrics: true,
        onAddValues: {}
    )
    .padding()
    .background(AppColor.background)
}
