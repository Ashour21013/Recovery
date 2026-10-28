import SwiftUI

/// Atemübung im Figma-Stil: pulsierender Atemring mit Countdown.
struct BreathingStepView: View {
    let remainingSeconds: Int
    let progress: Double
    let isRunning: Bool
    let onStart: () -> Void

    @State private var inhale = false

    private var phaseText: String {
        guard isRunning else { return remainingSeconds == 0 ? "Gut gemacht!" : "Bereit?" }
        return (remainingSeconds / 4).isMultiple(of: 2) ? "Einatmen · 4 Sekunden" : "Ausatmen · 4 Sekunden"
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            ZStack {
                Circle()
                    .fill(RadialGradient(colors: [Color(hex: 0x53B3A2, opacity: 0.45),
                                                  Color(hex: 0x439388, opacity: 0.14)],
                                         center: .center, startRadius: 0, endRadius: 95))
                    .overlay(Circle().stroke(Color(hex: 0x9EE2D4, opacity: 0.45), lineWidth: 1))
                    .background(Circle().fill(Color(hex: 0x51A798, opacity: 0.06)).padding(inhale ? -38 : -24))
                    .shadow(color: Color(hex: 0x60CEBB, opacity: inhale ? 0.22 : 0.15), radius: inhale ? 40 : 30)
                    .scaleEffect(inhale ? 1.13 : 1)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color(hex: 0x79C9B9), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .padding(-12)
                    .animation(.linear(duration: 1), value: progress)
                VStack(spacing: 0) {
                    Text("\(remainingSeconds)")
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .contentTransition(.numericText())
                        .monospacedDigit()
                    Text("Sekunden")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.65))
                }
            }
            .frame(width: 190, height: 190)
            .frame(height: 260)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Verbleibende Zeit")
            .accessibilityValue("\(remainingSeconds) Sekunden")

            Text("ATEMÜBUNG")
                .font(.caption2.weight(.heavy))
                .tracking(1.35)
                .foregroundStyle(.white.opacity(0.6))
                .padding(.top, 10)
            Text("Atme mit mir")
                .font(.system(size: 31, weight: .bold))
                .padding(.vertical, 10)
            Text(phaseText)
                .font(.body)
                .foregroundStyle(.white.opacity(0.72))

            if !isRunning && remainingSeconds > 0 {
                Button(action: onStart) {
                    Label("Atemübung starten", systemImage: "play.fill")
                        .font(.subheadline.weight(.bold))
                        .padding(.horizontal, 18)
                        .frame(minHeight: 44)
                        .background(Capsule().fill(.white.opacity(0.12)))
                }
                .buttonStyle(.plain)
                .padding(.top, AppSpacing.l)
            }
            Spacer(minLength: 0)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 22)
        .task(id: isRunning) {
            guard isRunning else {
                withAnimation(.smooth) { inhale = false }
                return
            }
            while !Task.isCancelled {
                withAnimation(.easeInOut(duration: 4)) { inhale.toggle() }
                try? await Task.sleep(for: .seconds(4))
            }
        }
    }
}
