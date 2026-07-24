import SwiftUI

/// Animierte, kreisförmige Illustration für die Onboarding-Screens.
///
/// Stellt ein SF-Symbol (oder ein Emoji) in einem weichen, mehrschichtigen
/// Farbverlaufs-Kreis dar und blendet es beim Erscheinen dezent ein.
/// Reine UI-Komponente – keine Geschäftslogik.
struct OnboardingIllustration: View {
    var systemImage: String? = nil
    var emoji: String? = nil
    var tint: Color = AppColor.accent

    @State private var appeared = false

    var body: some View {
        ZStack {
            Circle()
                .fill(tint.opacity(0.12))
                .frame(width: 160, height: 160)
                .scaleEffect(appeared ? 1 : 0.6)

            Circle()
                .fill(tint.opacity(0.16))
                .frame(width: 120, height: 120)
                .scaleEffect(appeared ? 1 : 0.5)

            content
                .scaleEffect(appeared ? 1 : 0.4)
                .opacity(appeared ? 1 : 0)
        }
        .shadow(color: tint.opacity(0.25), radius: appeared ? 20 : 0, y: 8)
        .animation(.spring(response: 0.55, dampingFraction: 0.6), value: appeared)
        .onAppear { appeared = true }
    }

    @ViewBuilder
    private var content: some View {
        if let emoji {
            Text(emoji)
                .font(.system(size: 64))
        } else if let systemImage {
            Image(systemName: systemImage)
                .font(.system(size: 60))
                .foregroundStyle(tint.gradient)
                .symbolRenderingMode(.hierarchical)
                .symbolEffect(.bounce, value: appeared)
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        OnboardingIllustration(systemImage: "heart.circle.fill")
        OnboardingIllustration(emoji: "🚭", tint: .orange)
    }
    .padding()
}
