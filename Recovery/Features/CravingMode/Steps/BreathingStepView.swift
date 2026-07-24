import SwiftUI

/// Atemübung mit 60-Sekunden-Countdown und animiertem Atemkreis.
/// Reine UI – Countdown-Logik liegt im ViewModel.
struct BreathingStepView: View {
    let remainingSeconds: Int
    let progress: Double
    let isRunning: Bool
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            VStack(spacing: AppSpacing.s) {
                Text("Atme ruhig")
                    .font(AppFont.title)
                Text("Ein durch die Nase, aus durch den Mund.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            ZStack {
                Circle()
                    .stroke(Color(.secondarySystemBackground), lineWidth: 14)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(AppColor.accent.gradient, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)

                Circle()
                    .fill(AppColor.accent.opacity(0.12))
                    .scaleEffect(isRunning ? 1.0 : 0.75)
                    .animation(
                        isRunning
                        ? .easeInOut(duration: 4).repeatForever(autoreverses: true)
                        : .default,
                        value: isRunning
                    )
                    .padding(28)

                Text("\(remainingSeconds)")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())
                    .monospacedDigit()
            }
            .frame(width: 240, height: 240)

            if !isRunning && remainingSeconds == 60 {
                PrimaryButton(title: "Atemübung starten", action: onStart)
            } else if remainingSeconds == 0 {
                Label("Gut gemacht!", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .foregroundStyle(.green)
                    .symbolEffect(.bounce, value: remainingSeconds)
                    .transition(.scale.combined(with: .opacity))
            } else {
                Text("Bleib dabei…")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .transition(.opacity)
            }
        }
        .padding(AppSpacing.l)
        .animation(.smooth, value: isRunning)
        .animation(.smooth, value: remainingSeconds == 0)
    }
}

#Preview {
    BreathingStepView(remainingSeconds: 42, progress: 0.3, isRunning: true, onStart: {})
}
