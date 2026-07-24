import SwiftUI

/// Wiederverwendbares Badge für ein Achievement.
///
/// Stellt Icon, Titel und (optional) Freischalt-Zustand dar. Gesperrte
/// Badges werden abgedunkelt/entsättigt gezeigt. Reine UI-Komponente.
struct AchievementBadge: View {
    let achievement: Achievement
    var size: CGFloat = 72

    private var tint: Color { achievement.type.colorName.color }

    var body: some View {
        VStack(spacing: AppSpacing.s) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? tint.opacity(0.18) : Color(.tertiarySystemFill))
                    .frame(width: size, height: size)

                Circle()
                    .stroke(achievement.isUnlocked ? tint : Color(.separator), lineWidth: 2)
                    .frame(width: size, height: size)

                Image(systemName: achievement.isUnlocked ? achievement.type.systemImage : "lock.fill")
                    .font(.system(size: size * 0.4))
                    .foregroundStyle(achievement.isUnlocked ? tint : .secondary)
                    .symbolRenderingMode(.hierarchical)
            }

            Text(achievement.type.title)
                .font(.caption.weight(.medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(achievement.isUnlocked ? .primary : .secondary)
                .lineLimit(2)
                .frame(maxWidth: size + 24)
        }
        .opacity(achievement.isUnlocked ? 1 : 0.7)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(achievement.type.title), \(achievement.isUnlocked ? "freigeschaltet" : "gesperrt")")
    }
}

#Preview {
    HStack(spacing: AppSpacing.l) {
        AchievementBadge(achievement: Achievement(type: .sevenDays, unlockedAt: .now))
        AchievementBadge(achievement: Achievement(type: .oneYear, unlockedAt: nil))
    }
    .padding()
}
