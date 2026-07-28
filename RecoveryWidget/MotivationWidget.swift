import WidgetKit
import SwiftUI
import AppIntents

/// Timeline-Eintrag für das reine Motivations-Widget.
struct MotivationEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
    let quote: WidgetQuote?
}

/// Timeline-Provider für das Motivations-Widget. Liest nur aus der App Group
/// und wechselt den Spruch zum Tageswechsel. Berücksichtigt die im Widget
/// gewählte Spruch-Quelle.
struct MotivationTimelineProvider: AppIntentTimelineProvider {

    private let store = WidgetSnapshotStore()

    func placeholder(in context: Context) -> MotivationEntry {
        entry(from: .placeholder, source: .quotes, date: .now)
    }

    func snapshot(for configuration: SelectQuoteSourceIntent, in context: Context) async -> MotivationEntry {
        entry(from: store.load() ?? .placeholder, source: configuration.source.widgetSource, date: .now)
    }

    func timeline(for configuration: SelectQuoteSourceIntent, in context: Context) async -> Timeline<MotivationEntry> {
        let snapshot = store.load() ?? .placeholder
        let now = Date.now
        return Timeline(
            entries: [entry(from: snapshot, source: configuration.source.widgetSource, date: now)],
            policy: .after(nextMidnight(after: now))
        )
    }

    private func entry(from snapshot: WidgetSnapshot, source: WidgetQuoteSource, date: Date) -> MotivationEntry {
        MotivationEntry(date: date, snapshot: snapshot, quote: snapshot.quote(for: date, source: source))
    }

    private func nextMidnight(after date: Date) -> Date {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        return calendar.date(byAdding: .day, value: 1, to: start) ?? date.addingTimeInterval(3600)
    }
}

/// Anzeige des Motivations-Widgets (Light/Dark, Dynamic Type). Zeigt nur den
/// täglichen Motivationsspruch – keine Streak.
struct MotivationWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: MotivationEntry

    var body: some View {
        Group {
            if entry.snapshot.isPremium {
                content
            } else {
                lockedTeaser
            }
        }
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [Color.accentColor.opacity(0.18), Color(.systemBackground)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "quote.opening")
                .font(.title3)
                .foregroundStyle(Color.accentColor)

            if let quote = entry.quote {
                Text(quote.text)
                    .font(family == .systemSmall ? .caption.weight(.medium) : .headline.weight(.medium))
                    .foregroundStyle(.primary)
                    .lineLimit(family == .systemSmall ? 5 : 4)
                    .minimumScaleFactor(0.7)
                if let author = quote.author {
                    Text("— \(author)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var lockedTeaser: some View {
        VStack(spacing: 6) {
            Image(systemName: "lock.fill")
                .font(.headline)
                .foregroundStyle(.white)
                .padding(8)
                .background(Circle().fill(Color.accentColor))
            Text("Premium freischalten")
                .font(.subheadline.weight(.semibold))
                .multilineTextAlignment(.center)
            Text("Täglicher Motivationsspruch auf deinem Home-Bildschirm.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Reines Motivations-Widget: zeigt ausschließlich den täglichen Spruch.
struct MotivationWidget: Widget {
    private let kind = "MotivationWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectQuoteSourceIntent.self,
            provider: MotivationTimelineProvider()
        ) { entry in
            MotivationWidgetView(entry: entry)
        }
        .configurationDisplayName("Tägliche Motivation")
        .description("Dein täglicher Motivationsspruch auf einen Blick.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemMedium) {
    MotivationWidget()
} timeline: {
    MotivationEntry(date: .now, snapshot: .placeholder, quote: WidgetSnapshot.placeholder.quote())
}
