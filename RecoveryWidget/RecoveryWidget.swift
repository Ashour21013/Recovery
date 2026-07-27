import WidgetKit
import SwiftUI

/// Konfiguration des Recovery-Home-Screen-Widgets.
///
/// Zeigt Streak, Fortschritt und einen tagesaktuellen Motivationsspruch.
/// Unterstützt die Größen systemSmall und systemMedium.
struct RecoveryWidget: Widget {
    private let kind = "RecoveryWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectAddictionIntent.self,
            provider: RecoveryTimelineProvider()
        ) { entry in
            RecoveryWidgetView(entry: entry)
        }
        .configurationDisplayName("Recovery")
        .description("Deine Streak und tägliche Motivation auf einen Blick.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    RecoveryWidget()
} timeline: {
    RecoveryEntry(
        date: .now,
        snapshot: .placeholder,
        addiction: WidgetSnapshot.placeholder.resolvedAddiction(preferredID: nil),
        quote: WidgetSnapshot.placeholder.quote()
    )
}

#Preview(as: .systemMedium) {
    RecoveryWidget()
} timeline: {
    RecoveryEntry(
        date: .now,
        snapshot: .placeholder,
        addiction: WidgetSnapshot.placeholder.resolvedAddiction(preferredID: nil),
        quote: WidgetSnapshot.placeholder.quote()
    )
}
