import WidgetKit
import SwiftUI

/// Anzeige-Views des Recovery-Widgets.
///
/// Reine Präsentation der geteilten Daten – keine Business-Logik. Unterstützt
/// systemSmall & systemMedium sowie Light/Dark Mode und Dynamic Type.
struct RecoveryWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: RecoveryEntry

    var body: some View {
        Group {
            if entry.snapshot.isPremium {
                switch family {
                case .systemSmall: SmallWidgetView(entry: entry)
                default: MediumWidgetView(entry: entry)
                }
            } else {
                LockedWidgetView(family: family)
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
}

// MARK: - Small

private struct SmallWidgetView: View {
    let entry: RecoveryEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: entry.snapshot.addictionSystemImage)
                    .font(.caption)
                    .foregroundStyle(Color.accentColor)
                Text(entry.snapshot.addictionTitle)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            Text("\(entry.streakDays)")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Text("Tage clean")
                .font(.caption2)
                .foregroundStyle(.secondary)

            Spacer(minLength: 0)

            if let quote = entry.quote {
                Text(quote.text)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Medium

private struct MediumWidgetView: View {
    let entry: RecoveryEntry

    var body: some View {
        HStack(spacing: 14) {
            // Streak-Block.
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: entry.snapshot.addictionSystemImage)
                        .font(.caption)
                        .foregroundStyle(Color.accentColor)
                    Text(entry.snapshot.addictionTitle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Text("\(entry.streakDays)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                Text("Tage clean")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 0)

                Label("Rekord: \(entry.snapshot.longestStreakDays) Tage", systemImage: "trophy.fill")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            // Motivations-Block.
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "quote.opening")
                    .font(.caption)
                    .foregroundStyle(Color.accentColor)

                if let quote = entry.quote {
                    Text(quote.text)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.primary)
                        .lineLimit(4)
                        .minimumScaleFactor(0.8)
                    if let author = quote.author {
                        Text("— \(author)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Locked (Free)

/// Teaser für Free-Nutzer: zeigt eine dezent verblurrte Beispiel-Vorschau des
/// echten Widgets im Hintergrund, darüber gut lesbar Schloss, Titel und Nutzen.
private struct LockedWidgetView: View {
    let family: WidgetFamily

    /// Demo-Snapshot rein zur Veranschaulichung (keine echten Nutzerdaten).
    private var demoEntry: RecoveryEntry {
        RecoveryEntry(
            date: .now,
            snapshot: .placeholder,
            quote: WidgetSnapshot.placeholder.quote()
        )
    }

    var body: some View {
        ZStack {
            // Verblurrte Beispiel-Vorschau des echten Widgets.
            Group {
                if family == .systemSmall {
                    SmallWidgetView(entry: demoEntry)
                } else {
                    MediumWidgetView(entry: demoEntry)
                }
            }
            .blur(radius: 5)
            .opacity(0.5)
            .accessibilityHidden(true)

            // Abdunkelung für gute Lesbarkeit des Overlays.
            Color(.systemBackground).opacity(0.25)

            // Klarer Vordergrund.
            VStack(spacing: 6) {
                Image(systemName: "lock.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(Circle().fill(Color.accentColor))
                Text("Premium freischalten")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                Text("Streak & tägliche Motivation direkt auf dem Home-Bildschirm.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
