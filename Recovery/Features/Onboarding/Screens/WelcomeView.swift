import SwiftUI

/// Screen 1 – Willkommen (Figma): Eyebrow, große Headline, App-Logo,
/// Pflanzen-Illustration, Verlaufs-Button und Datenschutz-Hinweis.
struct WelcomeView: View {
    let onContinue: () -> Void

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            OnboardingProgressBar(currentStep: 1, totalSteps: OnboardingStep.total + 1)
                .padding(.top, 8)

            VStack(spacing: 12) {
                Eyebrow(String(localized: "Willkommen bei Recovery"))
                Text("Dein Weg zurück zu dir.")
                    .font(.system(size: 32, weight: .semibold))
                    .tracking(-0.6)
                    .foregroundStyle(AppColor.ink)
                    .multilineTextAlignment(.center)
                Text("Kleine Schritte. Echte Fortschritte. Und Unterstützung genau dann, wenn du sie brauchst.")
                    .font(.callout)
                    .foregroundStyle(AppColor.muted)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 30)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)

            VStack(spacing: 12) {
                RecoveryLogoMark()
                    .scaleEffect(appeared ? 1 : 0.85)
                HStack(spacing: 0) {
                    Text("recovery").foregroundStyle(AppColor.ink)
                    Text(".").foregroundStyle(AppColor.coral)
                }
                .font(.system(size: 26, weight: .heavy))
                .tracking(-0.8)
            }
            .padding(.top, 26)
            .opacity(appeared ? 1 : 0)

            Spacer(minLength: 20)

            WelcomePlantScene()
                .frame(height: 170)
                .padding(.horizontal, 12)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)

            Button(action: onContinue) {
                HStack {
                    Spacer()
                    Text("Los geht’s")
                    Spacer()
                    Image(systemName: "arrow.right")
                }
                .padding(.horizontal, 22)
            }
            .buttonStyle(GradientCTAButtonStyle())
            .padding(.top, 8)

            Label("Deine Daten bleiben privat und gehören dir.", systemImage: "shield")
                .font(.caption)
                .foregroundStyle(AppColor.muted)
                .padding(.top, 12)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
        .background(
            LinearGradient(colors: [AppColor.background, AppColor.mint.opacity(0.5)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
        .toolbar(.hidden, for: .navigationBar)
        .animation(.smooth(duration: 0.6).delay(0.1), value: appeared)
        .onAppear { appeared = true }
    }
}

/// App-Logo: Schild mit Keimling auf Teal-Kachel.
struct RecoveryLogoMark: View {
    var size: CGFloat = 96

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.27, style: .continuous)
                .fill(LinearGradient(colors: [Color(hex: 0x3E8C82), Color(hex: 0x2F7069)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
            Image(systemName: "shield")
                .font(.system(size: size * 0.58, weight: .semibold))
                .foregroundStyle(.white)
            SproutGlyph()
                .stroke(.white, style: StrokeStyle(lineWidth: size * 0.045, lineCap: .round, lineJoin: .round))
                .frame(width: size * 0.32, height: size * 0.3)
                .offset(y: size * 0.03)
        }
        .frame(width: size, height: size)
        .shadow(color: AppColor.deep.opacity(0.25), radius: 16, y: 10)
        .accessibilityHidden(true)
    }
}

/// Keimling mit zwei Blättern (für das Logo).
private struct SproutGlyph: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        let stemTop = CGPoint(x: r.midX, y: r.minY + r.height * 0.45)
        // Stiel
        p.move(to: CGPoint(x: r.midX, y: r.maxY))
        p.addLine(to: stemTop)
        // linkes Blatt
        p.move(to: stemTop)
        p.addQuadCurve(to: CGPoint(x: r.minX, y: r.minY + r.height * 0.1),
                       control: CGPoint(x: r.minX + r.width * 0.05, y: r.minY + r.height * 0.55))
        p.addQuadCurve(to: stemTop,
                       control: CGPoint(x: r.midX, y: r.minY))
        // rechtes Blatt
        p.move(to: stemTop)
        p.addQuadCurve(to: CGPoint(x: r.maxX, y: r.minY),
                       control: CGPoint(x: r.midX, y: r.minY - r.height * 0.05))
        p.addQuadCurve(to: stemTop,
                       control: CGPoint(x: r.maxX - r.width * 0.05, y: r.minY + r.height * 0.5))
        return p
    }
}

/// Kleine Szene: Keimling im Topf, Sonne, sanfter Kartenhintergrund.
private struct WelcomePlantScene: View {
    @State private var sway = false

    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(LinearGradient(colors: [AppColor.surface.opacity(0.6), AppColor.mint.opacity(0.7)],
                                     startPoint: .top, endPoint: .bottom))
                .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(AppColor.line))

            Circle()
                .fill(Color(hex: 0xF6E7B0).opacity(0.6))
                .frame(width: 70, height: 70)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(.top, 6)
                .padding(.trailing, 10)

            Ellipse()
                .fill(AppColor.muted.opacity(0.18))
                .frame(width: 120, height: 14)
                .padding(.bottom, 2)

            VStack(spacing: -4) {
                ZStack(alignment: .bottom) {
                    Capsule().fill(Color(hex: 0x3E8C5E)).frame(width: 5, height: 92)
                    leaf(angle: -35, x: -20, y: -26)
                    leaf(angle: 35, x: 20, y: -40)
                    leaf(angle: -35, x: -18, y: -58)
                    leaf(angle: 30, x: 16, y: -76)
                }
                .rotationEffect(.degrees(sway ? 2 : -2), anchor: .bottom)
                PotShape()
                    .fill(Color(hex: 0x98694A))
                    .frame(width: 80, height: 30)
            }
            .padding(.bottom, 8)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) { sway = true }
        }
        .accessibilityHidden(true)
    }

    private func leaf(angle: Double, x: CGFloat, y: CGFloat) -> some View {
        Ellipse()
            .fill(Color(hex: 0x69A777))
            .overlay(Ellipse().stroke(Color(hex: 0x3E7A50), lineWidth: 1.5))
            .frame(width: 34, height: 17)
            .rotationEffect(.degrees(angle))
            .offset(x: x, y: y)
    }
}

private struct PotShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.minX, y: r.minY + r.height * 0.25))
        p.addQuadCurve(to: CGPoint(x: r.maxX, y: r.minY + r.height * 0.25),
                       control: CGPoint(x: r.midX, y: r.minY - r.height * 0.3))
        p.addLine(to: CGPoint(x: r.maxX - r.width * 0.15, y: r.maxY))
        p.addLine(to: CGPoint(x: r.minX + r.width * 0.15, y: r.maxY))
        p.closeSubpath()
        return p
    }
}

/// Großer Verlaufs-CTA (Figma „Los geht’s").
struct GradientCTAButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3.weight(.bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 62)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(LinearGradient(colors: [Color(hex: 0x3E8278), Color(hex: 0x2C625C)],
                                         startPoint: .leading, endPoint: .trailing))
            )
            .shadow(color: AppColor.deep.opacity(0.25), radius: 12, y: 6)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.smooth(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    NavigationStack { WelcomeView(onContinue: {}) }
}
