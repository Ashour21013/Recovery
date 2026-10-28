import SwiftUI

/// Meilenstein-Karte (Figma): Fortschrittsring mit Prozent, Eyebrow,
/// Zieltitel, „Noch X Tage“ und Fortschrittsbalken.
struct ProgressCardView: View {
    let progress: ProgressSummary
    var currentDays: Int = 0

    private var milestone: Milestone { Milestone.next(afterDays: currentDays) }
    private var fraction: Double { progress.clampedMilestoneFraction }
    private var percent: Int { Int((fraction * 100).rounded()) }
    private var remaining: Int { max(0, milestone.rawValue - currentDays) }

    private var subtitle: String {
        switch remaining {
        case 0: String(localized: "Geschafft – stark!")
        case 1: String(localized: "Noch 1 Tag. Gleich hast du es!")
        case 2...3: String(localized: "Noch \(remaining) Tage. Du bist fast da!")
        default: String(localized: "Noch \(remaining) Tage. Schritt für Schritt.")
        }
    }

    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle().stroke(Color(light: 0xDCEAE6, dark: 0x29433F), lineWidth: 7)
                Circle()
                    .trim(from: 0, to: fraction)
                    .stroke(AppColor.teal, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.smooth(duration: 0.8), value: fraction)
                VStack(spacing: 2) {
                    Image(systemName: "sparkles").font(.subheadline)
                    Text("\(percent)%")
                        .font(.system(.subheadline, design: .rounded).weight(.bold))
                        .contentTransition(.numericText())
                }
                .foregroundStyle(AppColor.teal)
            }
            .frame(width: 78, height: 78)

            VStack(alignment: .leading, spacing: 3) {
                Text("NÄCHSTER MEILENSTEIN")
                    .font(.caption2.weight(.heavy))
                    .tracking(1.35)
                    .foregroundStyle(AppColor.teal)
                Text("\(milestone.rawValue) Tage")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppColor.ink)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(AppColor.muted)
                    .padding(.bottom, 6)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color(light: 0xE2ECE9, dark: 0x29433F))
                        Capsule()
                            .fill(LinearGradient(colors: [AppColor.teal, Color(hex: 0x43AE9E)],
                                                 startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * fraction)
                    }
                }
                .frame(height: 6)
                .animation(.smooth(duration: 0.8), value: fraction)
            }
        }
        .padding(17)
        .frame(maxWidth: .infinity, alignment: .leading)
        .gainSurface(radius: AppRadius.card)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(localized: "Nächster Meilenstein \(milestone.rawValue) Tage, \(percent) Prozent. \(subtitle)"))
    }
}
