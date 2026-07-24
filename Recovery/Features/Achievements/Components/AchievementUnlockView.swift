import SwiftUI

/// Animiertes Overlay zur Feier einer Achievement-Freischaltung.
///
/// Zeigt das Badge groß mit einer Einblend-/Skalier-Animation. Bei mehreren
/// gleichzeitig freigeschalteten Achievements werden sie nacheinander gezeigt.
struct AchievementUnlockView: View {
    let achievements: [Achievement]
    var namespace: Namespace.ID?
    let onDismiss: () -> Void

    @State private var index = 0
    @State private var animate = false

    private var current: Achievement? {
        guard index < achievements.count else { return nil }
        return achievements[index]
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture(perform: advance)

            if let current {
                VStack(spacing: AppSpacing.l) {
                    Text("Achievement freigeschaltet!")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.9))

                    badge(for: current)

                    VStack(spacing: AppSpacing.xs) {
                        Text(current.type.title)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                        Text(current.type.details)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                    }

                    Button(action: advance) {
                        Text(index == achievements.count - 1 ? "Super!" : "Weiter")
                            .font(.headline)
                            .padding(.horizontal, AppSpacing.xl)
                            .padding(.vertical, AppSpacing.s)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.white)
                    .foregroundStyle(.black)
                }
                .padding(AppSpacing.xl)
                .transition(.scale.combined(with: .opacity))
                .id(index)
            }
        }
        .onAppear {
            triggerAnimation()
        }
    }

    private func badge(for achievement: Achievement) -> some View {
        let tint = achievement.type.colorName.color
        return ZStack {
            Circle()
                .fill(tint.opacity(0.25))
                .frame(width: 160, height: 160)
                .scaleEffect(animate ? 1.0 : 0.4)

            Circle()
                .stroke(tint, lineWidth: 3)
                .frame(width: 160, height: 160)
                .scaleEffect(animate ? 1.0 : 0.4)

            Image(systemName: achievement.type.systemImage)
                .font(.system(size: 68))
                .foregroundStyle(tint)
                .symbolRenderingMode(.hierarchical)
                .symbolEffect(.bounce, value: animate)
                .scaleEffect(animate ? 1.0 : 0.2)
                .rotationEffect(.degrees(animate ? 0 : -30))
        }
        .modifier(OptionalMatchedGeometry(id: achievement.id, namespace: namespace))
        .shadow(color: tint.opacity(0.6), radius: animate ? 24 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.55), value: animate)
    }

    private func triggerAnimation() {
        animate = false
        withAnimation { animate = true }
    }

    private func advance() {
        if index < achievements.count - 1 {
            index += 1
            triggerAnimation()
        } else {
            onDismiss()
        }
    }
}

/// Wendet `matchedGeometryEffect` nur an, wenn ein Namespace vorhanden ist.
private struct OptionalMatchedGeometry: ViewModifier {
    let id: String
    let namespace: Namespace.ID?

    func body(content: Content) -> some View {
        if let namespace {
            content.matchedGeometryEffect(id: id, in: namespace)
        } else {
            content
        }
    }
}

#Preview {
    AchievementUnlockView(
        achievements: [Achievement(type: .sevenDays, unlockedAt: .now)],
        onDismiss: {}
    )
}
