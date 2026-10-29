import SwiftUI
import WidgetKit

/// „Recovery-Garten“: Eine Pflanze, die mit jedem cleanen Tag wächst – und die man täglich gießen kann.
/// Stufen: 0 Samen · 1 Keimling (<7) · 2 Junge Pflanze (<14) · 3 Starke Pflanze (<30) · 4 Blüte (<90) · 5 Baum.
struct PlantCardView: View {
    let days: Int

    @AppStorage(PlantGarden.lastWateredKey, store: AppGroup.sharedDefaults) private var lastWateredDay = ""
    @AppStorage(PlantGarden.waterCountKey, store: AppGroup.sharedDefaults) private var waterCount = 0
    @AppStorage("plant.lastCelebratedStage") private var lastCelebratedStage = -1
    @State private var waterTrigger = 0
    @State private var tapTrigger = 0
    @State private var celebratingStage: Int?
    @State private var celebrationTrigger = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    static let maxStage = PlantGarden.maxStage
    private static let thresholds = PlantGarden.thresholds

    static func stage(for days: Int) -> Int { PlantGarden.stage(for: days) }

    private static func todayKey() -> String { PlantGarden.todayKey() }

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
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay { celebration }
        .task(id: stage) { await checkCelebration() }
        .task { await PlantGarden.refreshReminder() }
        .sensoryFeedback(.success, trigger: waterTrigger)
        .sensoryFeedback(.success, trigger: celebrationTrigger)
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
        PlantGarden.defaults.synchronize()
        WidgetCenter.shared.reloadAllTimelines()
        Task { await PlantGarden.refreshReminder() }
    }

    /// Feiert nur echte Aufstiege; beim ersten Start oder nach einem Rückfall wird still synchronisiert.
    private func checkCelebration() async {
        defer { lastCelebratedStage = stage }
        guard lastCelebratedStage >= 0, stage > lastCelebratedStage, stage > 0 else { return }
        celebrationTrigger += 1
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { celebratingStage = stage }
        try? await Task.sleep(for: .seconds(3.5))
        withAnimation(.easeOut(duration: 0.4)) { celebratingStage = nil }
    }

    @ViewBuilder
    private var celebration: some View {
        if let level = celebratingStage {
            ZStack {
                if !reduceMotion { ConfettiView() }
                VStack(spacing: 4) {
                    Text("Neue Stufe erreicht! 🎉")
                        .font(.headline.weight(.heavy))
                    Text(name(of: level))
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(Capsule().fill(AppColor.teal.shadow(.drop(radius: 8, y: 3))))
                .transition(.scale.combined(with: .opacity))
            }
            .allowsHitTesting(false)
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isStaticText)
        }
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
