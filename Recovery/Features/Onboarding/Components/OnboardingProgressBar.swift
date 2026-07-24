import SwiftUI

/// Segmentierte Fortschrittsanzeige für den Onboarding-Flow.
///
/// Zeigt einen Balken pro Schritt; bereits erreichte Schritte werden in der
/// Akzentfarbe gefüllt. Reine UI-Komponente, animiert den Fortschritt weich.
struct OnboardingProgressBar: View {
    /// Aktueller Schritt (1-basiert).
    let currentStep: Int
    /// Gesamtzahl der Schritte.
    let totalSteps: Int

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            ForEach(1...totalSteps, id: \.self) { step in
                Capsule()
                    .fill(step <= currentStep
                          ? AnyShapeStyle(AppColor.accent.gradient)
                          : AnyShapeStyle(Color(.systemFill)))
                    .frame(height: 6)
                    .frame(maxWidth: .infinity)
            }
        }
        .animation(.smooth(duration: 0.4), value: currentStep)
        .accessibilityElement()
        .accessibilityLabel("Schritt \(currentStep) von \(totalSteps)")
    }
}

#Preview {
    VStack(spacing: 20) {
        OnboardingProgressBar(currentStep: 1, totalSteps: 4)
        OnboardingProgressBar(currentStep: 3, totalSteps: 4)
        OnboardingProgressBar(currentStep: 4, totalSteps: 4)
    }
    .padding()
}
