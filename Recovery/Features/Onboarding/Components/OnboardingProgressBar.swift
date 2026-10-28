import SwiftUI

/// Figma-Fortschrittsanzeige: „Schritt x von n" plus schmaler Teal-Balken.
struct OnboardingProgressBar: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Eyebrow("Schritt \(currentStep) von \(totalSteps)")
                Spacer()
                Text("\(Int(Double(currentStep) / Double(totalSteps) * 100)) %")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(AppColor.muted)
                    .monospacedDigit()
            }
            BarProgress(fraction: Double(currentStep) / Double(totalSteps), height: 6)
        }
        .animation(.smooth(duration: 0.4), value: currentStep)
        .accessibilityElement()
        .accessibilityLabel("Schritt \(currentStep) von \(totalSteps)")
    }
}

#Preview {
    OnboardingProgressBar(currentStep: 2, totalSteps: 4).padding()
}
