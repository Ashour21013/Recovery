import SwiftUI

/// Erfolgs-Karte (Figma): Medaille mit Icon/Schloss, Titel, Status.
struct AchievementBadge: View {
    let achievement: Achievement
    var size: CGFloat = 75

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked
                          ? AnyShapeStyle(LinearGradient(colors: [Color(light: 0xD6F2E9, dark: 0x1C4842),
                                                                  Color(light: 0xA7DFCF, dark: 0x235A51)],
                                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                          : AnyShapeStyle(Color(light: 0xE9EFED, dark: 0x22322F)))
                    .shadow(color: achievement.isUnlocked ? Color(hex: 0x1A7E74, opacity: 0.14) : .clear,
                            radius: 9, y: 8)
                Image(systemName: achievement.isUnlocked ? achievement.type.systemImage : "lock.fill")
                    .font(.system(size: achievement.isUnlocked ? 30 : 22, weight: .semibold))
                    .foregroundStyle(achievement.isUnlocked ? AppColor.teal : Color(hex: 0x9AABA8))
                    .contentTransition(.symbolEffect(.replace))
                    .symbolEffect(.bounce, value: achievement.isUnlocked)
            }
            .frame(width: size, height: size)

            Text(achievement.type.title)
                .font(.footnote.weight(.bold))
                .foregroundStyle(achievement.isUnlocked ? AppColor.teal : AppColor.muted)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.top, 10)
            Text(achievement.isUnlocked ? String(localized: "Freigeschaltet") : String(localized: "In Arbeit"))
                .font(.caption2)
                .foregroundStyle(AppColor.muted)
                .padding(.top, 2)
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(achievement.isUnlocked
                      ? AnyShapeStyle(LinearGradient(colors: [Color(light: 0xF5FFFB, dark: 0x1B312E),
                                                              Color(light: 0xE6F5EE, dark: 0x1C3D37)],
                                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                      : AnyShapeStyle(AppColor.surface))
        )
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
            .stroke(achievement.isUnlocked ? Color(light: 0xC1E5DA, dark: 0x285148) : AppColor.line, lineWidth: 1))
        .animation(.smooth, value: achievement.isUnlocked)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(achievement.type.title), \(achievement.isUnlocked ? "freigeschaltet" : "gesperrt")")
    }
}
