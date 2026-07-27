import SwiftUI

/// Kompakte Darstellung eines Journal-Eintrags in der Liste.
/// Reine UI-Komponente ohne Geschäftslogik.
struct JournalEntryRow: View {
    let entry: JournalEntry

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.s) {
            HStack {
                if let mood = entry.moodValue {
                    Text(mood.emoji)
                        .font(.title3)
                }
                Text(entry.date, format: .dateTime.day().month().year())
                    .font(AppFont.subheadline.weight(.semibold))
                Spacer()
                if let trigger = entry.triggerName, !trigger.isEmpty {
                    Label(trigger, systemImage: "bolt.fill")
                        .font(AppFont.caption)
                        .foregroundStyle(.orange)
                        .labelStyle(.titleAndIcon)
                }
            }

            if !entry.text.isEmpty {
                Text(entry.text)
                    .font(AppFont.body)
                    .foregroundStyle(.primary)
                    .lineLimit(4)
            }
        }
        .padding(.vertical, AppSpacing.xs)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    JournalEntryRow(
        entry: JournalEntry(
            text: "Heute war ein guter Tag, wenig Verlangen.",
            mood: 4,
            triggerName: "Stress"
        )
    )
    .padding()
}
