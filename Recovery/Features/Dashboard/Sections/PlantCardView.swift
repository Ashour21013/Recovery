import SwiftUI

/// „Recovery-Garten“: Eine Pflanze, die mit jedem cleanen Tag wächst – und die man täglich gießen kann.
/// Stufen: 0 Samen · 1 Keimling (<7) · 2 Junge Pflanze (<14) · 3 Starke Pflanze (<30) · 4 Blüte (<90) · 5 Baum.
struct PlantCardView: View {
    let days: Int

    @AppStorage("plant.lastWateredDay") private var lastWateredDay = ""
    @AppStorage("plant.waterCount") private var waterCount = 0
    @State private var waterTrigger = 0
    @State private var tapTrigger = 0

    static let maxStage = 5
    private static let thresholds = [1, 7, 14, 30, 90]

    static func stage(for days: Int) -> Int {
        thresholds.filter { days >= $0 }.count
    }

    private static func todayKey() -> String {
        let c = Calendar.current.dateComponents([.year, .month, .day], from: .now)
        return "\(c.year ?? 0)-\(c.month ?? 0)-\(c.day ?? 0)"
    }

    private var stage: Int { Self.stage(for: days) }
    private var wateredToday: Bool { lastWateredDay == Self.todayKey() }

    private var title: String {
        switch stage {
        case 0: String(localized: "Ein neuer Anfang")
        case 1, 2: String(localized: "Du wächst jeden Tag")
        case 5: String(localized: "Ein starker Baum")
        default: String(localized: "Deine Stärke wird sichtbar")
        }
    }

    private func name(of stage: Int) -> String {
        [String(localized: "Samen"), String(localized: "Keimling"), String(localized: "Junge Pflanze"),
         String(localized: "Starke Pflanze"), String(localized: "In voller Blüte"),
         String(localized: "Kleiner Baum")][stage]
    }

    private var stageName: String { name(of: stage) }

    private var growthText: String {
        if stage == 0 {
            return String(localized: "Auch der kleinste Samen trägt einen Neuanfang in sich.")
        } else if days == 1 {
            return String(localized: "Deine Pflanze wächst seit 1 Tag mit dir.")
        } else {
            return String(localized: "Deine Pflanze wächst seit \(days) Tagen mit dir.")
        }
    }

    private var remainingDays: Int? {
        stage >= Self.maxStage ? nil : Self.thresholds[stage] - days
    }

    private var stageProgress: Double {
        guard stage < Self.maxStage else { return 1 }
        let lower = stage == 0 ? 0 : Self.thresholds[stage - 1]
        let upper = Self.thresholds[stage]
        return min(1, max(0, Double(days - lower) / Double(upper - lower)))
    }

    private var nextStageText: String {
        guard let remaining = remainingDays else { return String(localized: "Höchste Stufe erreicht") }
        let next = name(of: stage + 1)
        return remaining == 1
            ? String(localized: "Noch 1 Tag bis „\(next)“")
            : String(localized: "Noch \(remaining) Tage bis „\(next)“")
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
                Text(growthText)
                    .font(.caption)
                    .foregroundStyle(AppColor.muted)

                VStack(alignment: .leading, spacing: 4) {
                    ProgressView(value: stageProgress)
                        .tint(AppColor.teal)
                    Text(nextStageText)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(AppColor.teal)
                }
                .padding(.top, 4)

                Spacer(minLength: 8)

                HStack(spacing: 6) {
                    Button(action: water) {
                        Label(wateredToday ? String(localized: "Heute gegossen") : String(localized: "Gießen"),
                              systemImage: wateredToday ? "checkmark.circle.fill" : "drop.fill")
                            .font(.caption2.weight(.heavy))
                            .foregroundStyle(wateredToday ? AppColor.teal : .white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background(Capsule().fill(wateredToday ? Color.white.opacity(0.7) : AppColor.teal))
                    }
                    .buttonStyle(.plain)
                    .disabled(wateredToday)
                    .accessibilityHint(String(localized: "Gieße deine Pflanze einmal am Tag."))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            ZStack(alignment: .bottomLeading) {
                PlantIllustration(stage: stage, waterTrigger: waterTrigger, tapTrigger: tapTrigger)
                    .frame(width: 150, height: 160)
                    .contentShape(Rectangle())
                    .onTapGesture(perform: tapPlant)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(String(localized: "Recovery-Garten: \(stageName), Stufe \(stage + 1) von \(Self.maxStage + 1), \(days) Tage"))
            }
            .padding(.trailing, -10)
            .padding(.bottom, -19)
        }
        .padding(19)
        .frame(minHeight: 200)
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
        .sensoryFeedback(.success, trigger: waterTrigger)
        .sensoryFeedback(.impact(weight: .light), trigger: tapTrigger)
    }

    private func tapPlant() {
        if wateredToday { tapTrigger += 1 } else { water() }
    }

    private func water() {
        guard !wateredToday else { return }
        lastWateredDay = Self.todayKey()
        waterCount += 1
        waterTrigger += 1
    }
}

/// Zeichnet die Pflanze im 150×160-Koordinatensystem des Figma-SVGs.
/// Sie wiegt sich leicht im Wind, federt beim Antippen und wird beim Gießen mit Tropfen bedacht.
struct PlantIllustration: View {
    let stage: Int
    var waterTrigger = 0
    var tapTrigger = 0

    @State private var appeared = false
    @State private var pop: CGFloat = 0
    @State private var rain: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let stemColor = Color(hex: 0x347C5D)
    private let leafColor = Color(hex: 0x51A97A)
    private let trunkColor = Color(hex: 0x8A5F43)

    var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            GeometryReader { geo in
                let s = min(geo.size.width / 150, geo.size.height / 160)
                ZStack {
                    Ellipse().fill(Color(hex: 0x14463D, opacity: 0.12))
                        .frame(width: 102 * s, height: 16 * s)
                        .position(x: 75 * s, y: 145 * s)

                    plant(s)
                        .rotationEffect(.degrees(reduceMotion ? 0 : sin(t * 1.3) * 1.8),
                                        anchor: UnitPoint(x: 0.5, y: 0.85))
                        .scaleEffect(x: 1 + 0.05 * pop, y: 1 + 0.09 * pop, anchor: .bottom)

                    if stage >= 3 && !reduceMotion { sparkles(t: t, s: s) }
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
                .scaleEffect(appeared ? 1 : 0, anchor: .bottom)
                .animation(.spring(response: 0.7, dampingFraction: 0.6).delay(Double(i) * 0.08), value: appeared)
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
        PlantCardView(days: 120)
    }
    .padding()
}
