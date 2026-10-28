import SwiftUI

/// Figma-Fortschrittsanzeige: zentriertes „x von n" über einem dünnen Balken.
struct OnboardingProgressBar: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        VStack(spacing: 14) {
            Text("\(currentStep) von \(totalSteps)")
                .font(.footnote)
                .foregroundStyle(AppColor.muted)
                .monospacedDigit()
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(AppColor.line)
                    Capsule().fill(AppColor.teal)
                        .frame(width: geo.size.width * CGFloat(currentStep) / CGFloat(max(totalSteps, 1)))
                }
            }
            .frame(height: 4)
        }
        .animation(.smooth(duration: 0.4), value: currentStep)
        .accessibilityElement()
        .accessibilityLabel("Schritt \(currentStep) von \(totalSteps)")
    }
}

#Preview {
    OnboardingProgressBar(currentStep: 1, totalSteps: 5).padding()
}
