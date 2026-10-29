import SwiftUI

/// Zeichnet die Pflanze im 150×160-Koordinatensystem des Figma-SVGs.
/// Sie wiegt sich leicht im Wind, federt beim Antippen und wird beim Gießen mit Tropfen bedacht.
struct PlantIllustration: View {
    let stage: Int
    var waterTrigger = 0
    var tapTrigger = 0
    /// `false` für Widgets: statisches Bild ohne Wind, Funkeln und Einblend-Animation.
    var animated = true

    @State private var appeared = false
    @State private var pop: CGFloat = 0
    @State private var rain: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var shown: Bool { appeared || !animated }

    private let stemColor = Color(hex: 0x347C5D)
    private let leafColor = Color(hex: 0x51A97A)
    private let trunkColor = Color(hex: 0x8A5F43)

    var body: some View {
        TimelineView(.animation(paused: reduceMotion || !animated)) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            let still = reduceMotion || !animated
            GeometryReader { geo in
                let s = min(geo.size.width / 150, geo.size.height / 160)
                ZStack {
                    Ellipse().fill(Color(hex: 0x14463D, opacity: 0.12))
                        .frame(width: 102 * s, height: 16 * s)
                        .position(x: 75 * s, y: 145 * s)

                    plant(s)
                        .rotationEffect(.degrees(still ? 0 : sin(t * 1.3) * 1.8),
                                        anchor: UnitPoint(x: 0.5, y: 0.85))
                        .scaleEffect(x: 1 + 0.05 * pop, y: 1 + 0.09 * pop, anchor: .bottom)

                    if stage >= 3 && !still { sparkles(t: t, s: s) }
                    rainDrops(s)

                    // Erde
                    soil(s)
                }
            }
        }
        .onAppear { appeared = true }
        .animation(.spring(response: 0.6, dampingFraction: 0.6), value: stage)
        .onChange(of: tapTrigger) { _, _ in bounce() }
        .onChange(of: waterTrigger) { _, _ in
            bounce()
            rain = 0
            withAnimation(.easeIn(duration: 1.1)) { rain = 1 }
        }
    }

    private func bounce() {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.4)) { pop = 1 }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.5).delay(0.12)) { pop = 0 }
    }

    @ViewBuilder
    private func plant(_ s: CGFloat) -> some View {
        ZStack {
            if stage == 0 {
                Ellipse().fill(Color(hex: 0x7B553C))
                    .frame(width: 22 * s, height: 12 * s)
                    .position(x: 75 * s, y: 128 * s)
            } else if stage >= 5 {
                tree(s)
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
        }
    }

    @ViewBuilder
    private func tree(_ s: CGFloat) -> some View {
        shape { p in
            p.move(to: pt(67, 134, s))
            p.addCurve(to: pt(71, 74, s), control1: pt(70, 112, s), control2: pt(68, 90, s))
            p.addLine(to: pt(80, 74, s))
            p.addCurve(to: pt(83, 134, s), control1: pt(82, 90, s), control2: pt(80, 112, s))
            p.closeSubpath()
        }
        .fill(trunkColor)

        ForEach(Array([(75.0, 52.0, 30.0), (52, 66, 22), (98, 66, 22), (62, 40, 20), (88, 40, 20)].enumerated()), id: \.offset) { i, c in
            Circle().fill(i.isMultiple(of: 2) ? leafColor : Color(hex: 0x45976C))
                .overlay(Circle().stroke(stemColor, lineWidth: 2 * s))
                .frame(width: c.2 * 2 * s, height: c.2 * 2 * s)
                .position(x: c.0 * s, y: c.1 * s)
                .scaleEffect(shown ? 1 : 0, anchor: .bottom)
                .animation(.spring(response: 0.7, dampingFraction: 0.6).delay(Double(i) * 0.08), value: shown)
        }
        ForEach(Array([(66.0, 56.0), (86, 48), (96, 70), (54, 70), (76, 38)].enumerated()), id: \.offset) { _, c in
            Circle().fill(Color(hex: 0xE8685A))
                .frame(width: 9 * s, height: 9 * s)
                .position(x: c.0 * s, y: c.1 * s)
        }
    }

    private func soil(_ s: CGFloat) -> some View {
        shape { p in
            p.move(to: pt(37, 132, s))
            p.addCurve(to: pt(113, 132, s), control1: pt(44, 113, s), control2: pt(106, 113, s))
            p.addLine(to: pt(105, 152, s))
            p.addLine(to: pt(45, 152, s))
            p.closeSubpath()
        }
        .fill(Color(hex: 0x9B6F50))
    }

    private func sparkles(t: TimeInterval, s: CGFloat) -> some View {
        ZStack {
            ForEach(0..<4, id: \.self) { i in
                let phase = t * 0.7 + Double(i) * 1.7
                Circle().fill(Color(hex: 0xFFE9A6))
                    .frame(width: 4 * s, height: 4 * s)
                    .opacity(0.45 + 0.45 * sin(phase * 2))
                    .position(x: (75 + 46 * cos(phase + Double(i))) * s,
                              y: (70 + 34 * sin(phase * 0.8 + Double(i) * 2)) * s)
            }
        }
        .allowsHitTesting(false)
    }

    private func rainDrops(_ s: CGFloat) -> some View {
        ZStack {
            ForEach(0..<6, id: \.self) { i in
                let progress = min(1, max(0, rain * 1.5 - CGFloat(i) * 0.1))
                Image(systemName: "drop.fill")
                    .font(.system(size: 9 * s))
                    .foregroundStyle(Color(hex: 0x5BB5E8))
                    .position(x: (50 + CGFloat(i) * 10) * s, y: (-5 + progress * 120) * s)
                    .opacity(progress > 0 && progress < 1 ? 1 : 0)
            }
        }
        .allowsHitTesting(false)
    }

    private func pt(_ x: CGFloat, _ y: CGFloat, _ s: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }

    private func shape(_ build: @escaping (inout Path) -> Void) -> Path {
        var p = Path(); build(&p); return p
    }

    private func leaf(_ s: CGFloat, delay: Double, _ build: @escaping (inout Path) -> Void) -> some View {
        let path = shape(build)
        return path.fill(leafColor)
            .overlay(path.stroke(stemColor, style: StrokeStyle(lineWidth: 2 * s, lineJoin: .round)))
            .scaleEffect(shown ? 1 : 0, anchor: UnitPoint(x: 0.5, y: 0.75))
            .opacity(shown ? 1 : 0)
            .animation(.spring(response: 0.7, dampingFraction: 0.6).delay(delay), value: shown)
    }
}

