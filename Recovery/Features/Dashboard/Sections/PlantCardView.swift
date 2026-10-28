import SwiftUI

/// „Recovery-Garten“: Eine Pflanze, die mit jedem cleanen Tag wächst.
/// Stufen: 0 Samen · 1 Keimling (<7) · 2 Junge Pflanze (<14) · 3 Starke Pflanze (<30) · 4 Blüte.
struct PlantCardView: View {
    let days: Int

    static func stage(for days: Int) -> Int {
        switch days {
        case ..<1: 0
        case ..<7: 1
        case ..<14: 2
        case ..<30: 3
        default: 4
        }
    }

    private var stage: Int { Self.stage(for: days) }

    private var title: String {
        switch stage {
        case 0: "Ein neuer Anfang"
        case 1, 2: "Du wächst jeden Tag"
        default: "Deine Stärke wird sichtbar"
        }
    }

    private var stageName: String {
        ["Samen", "Keimling", "Junge Pflanze", "Starke Pflanze", "In voller Blüte"][stage]
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                Text("DEIN RECOVERY-GARTEN")
                    .font(.caption2.weight(.heavy))
                    .tracking(1.3)
                    .foregroundStyle(AppColor.muted)
                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(AppColor.ink)
                Text(stage == 0
                     ? "Auch der kleinste Samen trägt einen Neuanfang in sich."
                     : "Deine Pflanze wächst seit \(days) \(days == 1 ? "Tag" : "Tagen") mit dir.")
                    .font(.caption)
                    .foregroundStyle(AppColor.muted)
                Spacer(minLength: 8)
                Text(stageName)
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(AppColor.teal)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(.white.opacity(0.7)))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            PlantIllustration(stage: stage)
                .frame(width: 150, height: 160)
                .padding(.trailing, -10)
                .padding(.bottom, -19)
        }
        .padding(19)
        .frame(minHeight: 186)
        .background(
            ZStack(alignment: .topTrailing) {
                LinearGradient(colors: [Color(light: 0xEDF8F1, dark: 0x173731),
                                        Color(light: 0xD9EEE5, dark: 0x1A3F37)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                Circle().fill(Color(hex: 0xFFDC91, opacity: 0.23))
                    .frame(width: 80, height: 80)
                    .offset(x: 16, y: -17)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        )
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous)
            .stroke(Color(light: 0xCDE5DC, dark: 0x285148), lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Recovery-Garten: \(stageName), Stufe \(stage + 1) von 5, \(days) Tage")
    }
}

/// Zeichnet die Pflanze im 150×160-Koordinatensystem des Figma-SVGs.
struct PlantIllustration: View {
    let stage: Int
    @State private var appeared = false

    private let stemColor = Color(hex: 0x347C5D)
    private let leafColor = Color(hex: 0x51A97A)

    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width / 150, geo.size.height / 160)
            ZStack {
                Ellipse().fill(Color(hex: 0x14463D, opacity: 0.12))
                    .frame(width: 102 * s, height: 16 * s)
                    .position(x: 75 * s, y: 145 * s)

                if stage == 0 {
                    Ellipse().fill(Color(hex: 0x7B553C))
                        .frame(width: 22 * s, height: 12 * s)
                        .position(x: 75 * s, y: 128 * s)
                } else {
                    shape { p in
                        p.move(to: pt(75, 132, s))
                        p.addCurve(to: pt(75, 49, s), control1: pt(72, 105, s), control2: pt(79, 78, s))
                    }
                    .stroke(stemColor, style: StrokeStyle(lineWidth: 5 * s, lineCap: .round))

                    leaf(s, delay: 0) { p in
                        p.move(to: pt(75, 112, s))
                        p.addCurve(to: pt(46, 87, s), control1: pt(56, 111, s), control2: pt(47, 101, s))
                        p.addCurve(to: pt(75, 112, s), control1: pt(64, 86, s), control2: pt(75, 94, s))
                    }
                    if stage >= 2 {
                        leaf(s, delay: 0.12) { p in
                            p.move(to: pt(76, 94, s))
                            p.addCurve(to: pt(106, 68, s), control1: pt(95, 93, s), control2: pt(105, 83, s))
                            p.addCurve(to: pt(76, 94, s), control1: pt(87, 67, s), control2: pt(76, 76, s))
                        }
                    }
                    if stage >= 3 {
                        leaf(s, delay: 0.22) { p in
                            p.move(to: pt(75, 78, s))
                            p.addCurve(to: pt(51, 54, s), control1: pt(59, 76, s), control2: pt(51, 67, s))
                            p.addCurve(to: pt(75, 78, s), control1: pt(67, 54, s), control2: pt(75, 62, s))
                        }
                        leaf(s, delay: 0.32) { p in
                            p.move(to: pt(75, 63, s))
                            p.addCurve(to: pt(98, 41, s), control1: pt(90, 62, s), control2: pt(98, 53, s))
                            p.addCurve(to: pt(75, 63, s), control1: pt(83, 41, s), control2: pt(75, 49, s))
                        }
                    }
                    if stage >= 4 {
                        ForEach(Array([(75.0, 39.0, 9.0), (65, 34, 8), (85, 34, 8), (68, 45, 8), (82, 45, 8)].enumerated()), id: \.offset) { _, c in
                            Circle().fill(Color(hex: 0xF1A993))
                                .overlay(Circle().stroke(Color(hex: 0xD67A66), lineWidth: 1.5))
                                .frame(width: c.2 * 2 * s, height: c.2 * 2 * s)
                                .position(x: c.0 * s, y: c.1 * s)
                        }
                        Circle().fill(Color(hex: 0xF2CB69))
                            .frame(width: 12 * s, height: 12 * s)
                            .position(x: 75 * s, y: 39 * s)
                    }
                }

                // Erde
                shape { p in
                    p.move(to: pt(37, 132, s))
                    p.addCurve(to: pt(113, 132, s), control1: pt(44, 113, s), control2: pt(106, 113, s))
                    p.addLine(to: pt(105, 152, s))
                    p.addLine(to: pt(45, 152, s))
                    p.closeSubpath()
                }
                .fill(Color(hex: 0x9B6F50))
            }
        }
        .onAppear { appeared = true }
        .animation(.spring(response: 0.6, dampingFraction: 0.6), value: stage)
    }

    private func pt(_ x: CGFloat, _ y: CGFloat, _ s: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }

    private func shape(_ build: @escaping (inout Path) -> Void) -> Path {
        var p = Path(); build(&p); return p
    }

    private func leaf(_ s: CGFloat, delay: Double, _ build: @escaping (inout Path) -> Void) -> some View {
        let path = shape(build)
        return path.fill(leafColor)
            .overlay(path.stroke(stemColor, style: StrokeStyle(lineWidth: 2 * s, lineJoin: .round)))
            .scaleEffect(appeared ? 1 : 0, anchor: UnitPoint(x: 0.5, y: 0.75))
            .opacity(appeared ? 1 : 0)
            .animation(.spring(response: 0.7, dampingFraction: 0.6).delay(delay), value: appeared)
    }
}

#Preview {
    VStack {
        PlantCardView(days: 0)
        PlantCardView(days: 12)
        PlantCardView(days: 40)
    }
    .padding()
}
