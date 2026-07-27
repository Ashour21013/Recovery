import SwiftUI

/// Screen 1 – Willkommen.
///
/// Heißt den Nutzer mit einer animierten Illustration und gestaffelt
/// erscheinenden Texten willkommen. Reine UI – meldet nur „Weiter".
struct WelcomeView: View {
    let onContinue: () -> Void

    @State private var appeared = false

    private let highlights: [(icon: String, text: String)] = [
        ("chart.line.uptrend.xyaxis", "Verfolge deine Fortschritte Tag für Tag"),
        ("hand.raised.fill", "Soforthilfe in Momenten des Verlangens"),
        ("trophy.fill", "Feiere Erfolge und erreiche deine Ziele")
    ]

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()

            OnboardingIllustration(systemImage: "heart.circle.fill")

            VStack(spacing: AppSpacing.s) {
                Text("Willkommen bei Recovery")
                    .font(AppFont.largeTitle)
                    .multilineTextAlignment(.center)

                Text("Dein persönlicher Begleiter auf dem Weg zu einem freieren Leben.")
                    .font(AppFont.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 16)

            VStack(alignment: .leading, spacing: AppSpacing.m) {
                ForEach(Array(highlights.enumerated()), id: \.offset) { index, item in
                    HStack(spacing: AppSpacing.m) {
                        Image(systemName: item.icon)
                            .font(.title3)
                            .foregroundStyle(AppColor.accent)
                            .frame(width: 32)
                            .accessibilityHidden(true)
                        Text(item.text)
                            .font(AppFont.subheadline)
                            .foregroundStyle(.primary)
                        Spacer(minLength: 0)
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(x: appeared ? 0 : -20)
                    .animation(.smooth(duration: 0.5).delay(0.3 + Double(index) * 0.12), value: appeared)
                }
            }
            .padding(.horizontal, AppSpacing.s)

            Spacer()

            PrimaryButton(title: "Los geht's", action: onContinue)
        }
        .padding(AppSpacing.l)
        .animation(.smooth(duration: 0.6).delay(0.15), value: appeared)
        .onAppear { appeared = true }
    }
}

#Preview {
    WelcomeView(onContinue: {})
}
