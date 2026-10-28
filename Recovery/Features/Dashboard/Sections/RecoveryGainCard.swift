import SwiftUI

/// Kompakte Gain-Kachel (Figma): farbige Icon-Kachel, große Zahl, Label.
struct RecoveryGainCard: View {
    let gain: RecoveryGain
    var tone: GainTone = .mint

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(systemName: gain.systemImage)
                .font(.body.weight(.semibold))
                .foregroundStyle(tone.foreground)
                .frame(width: 32, height: 32)
                .background(RoundedRectangle(cornerRadius: 11, style: .continuous).fill(tone.background))
                .padding(.bottom, 12)

            Text(gain.formattedValue)
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundStyle(AppColor.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .contentTransition(.numericText())

            Text(gain.title)
                .font(.caption2)
                .foregroundStyle(AppColor.muted)
                .lineLimit(2)
                .padding(.top, 3)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, minHeight: 112, alignment: .topLeading)
        .gainSurface(radius: 18)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(gain.title): \(gain.formattedValue). \(gain.detail)")
    }
}

/// Gesundheits-/Wohlbefinden-Meilenstein (ohne Zahl) als schmale Zeile.
struct RecoveryHealthRow: View {
    let gain: RecoveryGain

    var body: some View {
        HStack(spacing: 11) {
            Image(systemName: gain.systemImage)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColor.coral)
                .frame(width: 32, height: 32)
                .background(RoundedRectangle(cornerRadius: 11, style: .continuous).fill(AppColor.coralSoft))
            VStack(alignment: .leading, spacing: 2) {
                Text(gain.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColor.ink)
                Text(gain.detail)
                    .font(.caption)
                    .foregroundStyle(AppColor.muted)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .gainSurface(radius: 18)
        .accessibilityElement(children: .combine)
    }
}
