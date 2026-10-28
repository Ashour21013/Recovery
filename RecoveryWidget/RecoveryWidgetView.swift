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
                colors: [WidgetPalette.mint, WidgetPalette.surface],
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
                Image(systemName: entry.addiction.systemImage)
                    .font(.caption)
                    .foregroundStyle(WidgetPalette.teal)
                Text(entry.addiction.title)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(WidgetPalette.muted)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            Text("\(entry.streakDays)")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(WidgetPalette.ink)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Text("TAGE CLEAN")
                .tracking(1.1)
                .font(.caption2)
                .foregroundStyle(WidgetPalette.muted)

            Spacer(minLength: 0)

            if let quote = entry.quote {
                Text(quote.text)
                    .font(.caption2)
                    .foregroundStyle(WidgetPalette.muted)
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
                    Image(systemName: entry.addiction.systemImage)
                        .font(.caption)
                        .foregroundStyle(WidgetPalette.teal)
                    Text(entry.addiction.title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(WidgetPalette.muted)
                        .lineLimit(1)
                }

                Text("\(entry.streakDays)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(WidgetPalette.ink)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                Text("TAGE CLEAN")
                .tracking(1.1)
                    .font(.caption2)
                    .foregroundStyle(WidgetPalette.muted)

                Spacer(minLength: 0)

                Label("Rekord: \(entry.addiction.longestStreakDays) Tage", systemImage: "trophy.fill")
                    .font(.caption2)
                    .foregroundStyle(WidgetPalette.muted)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            // Motivations-Block.
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "quote.opening")
                    .font(.caption)
                    .foregroundStyle(WidgetPalette.teal)

                if let quote = entry.quote {
                    Text(quote.text)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(WidgetPalette.ink)
                        .lineLimit(4)
                        .minimumScaleFactor(0.8)
                    if let author = quote.author {
                        Text("— \(author)")
                            .font(.caption2)
                            .foregroundStyle(WidgetPalette.muted)
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
            addiction: WidgetSnapshot.placeholder.resolvedAddiction(preferredID: nil),
            quote: WidgetSnapshot.placeholder.quote(),
            configuredID: nil
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
            WidgetPalette.surface.opacity(0.35)

            // Klarer Vordergrund.
            VStack(spacing: 6) {
                Image(systemName: "lock.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(Circle().fill(WidgetPalette.teal))
                Text("Premium freischalten")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(WidgetPalette.ink)
                    .multilineTextAlignment(.center)
                Text("Streak & tägliche Motivation direkt auf dem Home-Bildschirm.")
                    .font(.caption2)
                    .foregroundStyle(WidgetPalette.muted)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Figma-Palette (Widget-Target hat keinen Zugriff auf AppColor)

enum WidgetPalette {
    static let teal = dyn(0x177E77, 0x3FB3A6)
    static let ink = dyn(0x17201F, 0xEEF3F1)
    static let muted = dyn(0x66716F, 0x9AA6A3)
    static let mint = dyn(0xE3F3EF, 0x16302D)
    static let surface = dyn(0xFFFFFF, 0x161C1B)

    private static func dyn(_ light: UInt32, _ dark: UInt32) -> Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? rgb(dark) : rgb(light) })
    }
    private static func rgb(_ v: UInt32) -> UIColor {
        UIColor(red: CGFloat((v >> 16) & 0xFF) / 255,
                green: CGFloat((v >> 8) & 0xFF) / 255,
                blue: CGFloat(v & 0xFF) / 255, alpha: 1)
    }
}
