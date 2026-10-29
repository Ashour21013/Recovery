import WidgetKit
import SwiftUI
import AppIntents

/// Gießt die Pflanze direkt aus dem Widget (interaktiv ab iOS 17).
struct WaterPlantIntent: AppIntent {
    static var title: LocalizedStringResource = "Pflanze gießen"
    static var isDiscoverable: Bool { false }

    func perform() async throws -> some IntentResult {
        if PlantGarden.markWatered() {
            await PlantGarden.refreshReminder()
        }
        WidgetCenter.shared.reloadTimelines(ofKind: GardenWidget.kind)
        return .result()
    }
}

struct GardenEntry: TimelineEntry {
    let date: Date
    let days: Int
    let wateredToday: Bool
    var stage: Int { PlantGarden.stage(for: days) }
}

struct GardenProvider: TimelineProvider {
    private let store = WidgetSnapshotStore()

    func placeholder(in context: Context) -> GardenEntry {
        GardenEntry(date: .now, days: 12, wateredToday: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (GardenEntry) -> Void) {
        completion(makeEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<GardenEntry>) -> Void) {
        let now = Date.now
        let midnight = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: now))
            ?? now.addingTimeInterval(3600)
        completion(Timeline(entries: [makeEntry(date: now)], policy: .after(midnight)))
    }

    private func makeEntry(date: Date) -> GardenEntry {
        let snapshot = store.load() ?? .placeholder
        let addiction = snapshot.resolvedAddiction(preferredID: nil)
        let start = Calendar.current.startOfDay(for: addiction.startDate)
        let elapsed = Calendar.current.dateComponents([.day], from: start, to: Calendar.current.startOfDay(for: date)).day ?? 0
        return GardenEntry(date: date, days: max(addiction.currentStreakDays, max(0, elapsed)),
                           wateredToday: PlantGarden.isWateredToday)
    }
}

struct GardenWidgetView: View {
    let entry: GardenEntry
    @Environment(\.widgetFamily) private var family

    private var stageName: String {
        [String(localized: "Samen"), String(localized: "Keimling"), String(localized: "Junge Pflanze"),
         String(localized: "Starke Pflanze"), String(localized: "In voller Blüte"),
         String(localized: "Kleiner Baum")][entry.stage]
    }

    var body: some View {
        Group {
            if family == .systemMedium {
                HStack(spacing: 8) {
                    info
                    plant
                }
            } else {
                VStack(spacing: 2) {
                    plant
                    info
                }
            }
        }
        .containerBackground(for: .widget) {
            LinearGradient(colors: [Color(light: 0xEDF8F1, dark: 0x173731),
                                    Color(light: 0xD9EEE5, dark: 0x1A3F37)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    private var plant: some View {
        PlantIllustration(stage: entry.stage, animated: false)
            .aspectRatio(150 / 160, contentMode: .fit)
            .accessibilityHidden(true)
    }

    private var info: some View {
        VStack(alignment: family == .systemMedium ? .leading : .center, spacing: 4) {
            Text(stageName)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(WidgetPalette.ink)
                .lineLimit(1)
            Text(entry.days == 1 ? String(localized: "1 Tag clean") : String(localized: "\(entry.days) Tage clean"))
                .font(.caption2)
                .foregroundStyle(WidgetPalette.muted)
            if entry.wateredToday {
                Label("Heute gegossen", systemImage: "checkmark.circle.fill")
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(WidgetPalette.teal)
            } else {
                Button(intent: WaterPlantIntent()) {
                    Label("Gießen", systemImage: "drop.fill")
                        .font(.caption2.weight(.heavy))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(WidgetPalette.teal))
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: family == .systemMedium ? .leading : .center)
    }
}

struct GardenWidget: Widget {
    nonisolated static let kind = "GardenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: GardenProvider()) { entry in
            GardenWidgetView(entry: entry)
        }
        .configurationDisplayName("Recovery-Garten")
        .description("Deine Pflanze wächst mit jedem Tag – gieße sie direkt hier.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    GardenWidget()
} timeline: {
    GardenEntry(date: .now, days: 12, wateredToday: false)
    GardenEntry(date: .now, days: 40, wateredToday: true)
}
