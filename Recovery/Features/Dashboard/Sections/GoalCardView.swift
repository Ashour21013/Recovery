import SwiftUI

/// Ziel-Karte im Figma-Stil („DEIN ZIEL“ mit Icon-Kachel und Fortschritt).
struct GoalCardView: View {
    let goalProgress: GoalProgress?
    let onSelectGoal: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 11) {
                IconTile(systemImage: goalProgress?.goal.systemImage ?? "target",
                         foreground: AppColor.coral, background: AppColor.coralSoft)
                VStack(alignment: .leading, spacing: 3) {
                    Eyebrow(String(localized: "Dein Ziel"))
                    Text(goalProgress.map { "\($0.goal.title) clean" } ?? String(localized: "Setze dir ein Ziel"))
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(AppColor.ink)
                }
                Spacer()
                if goalProgress != nil {
                    Button("Ändern", action: onSelectGoal)
                        .font(.caption.weight(.bold))
                }
            }

            if let progress = goalProgress {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(progress.currentDays)")
                            .font(.system(.title2, design: .rounded).weight(.bold))
                            .foregroundStyle(AppColor.teal)
                        Text("/ \(progress.goal.days) Tage")
                            .font(.caption)
                            .foregroundStyle(AppColor.muted)
                        Spacer()
                        Text(progress.isAchieved ? String(localized: "Erreicht 🎉") : String(localized: "Noch \(progress.remainingDays) Tage"))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(progress.isAchieved ? AppColor.green : AppColor.muted)
                    }
                    BarProgress(fraction: progress.fraction)
                }
            } else {
                Button(action: onSelectGoal) {
                    Label("Ziel festlegen", systemImage: "target")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppColor.teal)
                        .frame(maxWidth: .infinity, minHeight: 43)
                        .background(RoundedRectangle(cornerRadius: 13, style: .continuous)
                            .fill(Color(light: 0xEDF6F3, dark: 0x1A3934)))
                }
                .buttonStyle(.plain)
            }
        }
        .figmaCard()
    }
}

/// Dünner Fortschrittsbalken mit Teal-Verlauf.
struct BarProgress: View {
    let fraction: Double
    var height: CGFloat = 6

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color(light: 0xE2ECE9, dark: 0x29433F))
                Capsule()
                    .fill(LinearGradient(colors: [AppColor.teal, Color(hex: 0x43AE9E)],
                                         startPoint: .leading, endPoint: .trailing))
                    .frame(width: geo.size.width * min(1, max(0, fraction)))
            }
        }
        .frame(height: height)
        .animation(.smooth(duration: 0.6), value: fraction)
    }
}
