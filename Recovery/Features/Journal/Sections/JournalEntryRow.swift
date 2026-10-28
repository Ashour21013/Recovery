import SwiftUI

/// Tagebuch-Zeile (Figma): Stimmungs-Kreis, Datum, Titelzeile, Vorschau.
struct JournalEntryRow: View {
    let entry: JournalEntry

    private var dateText: String {
        let cal = Calendar.current
        let time = entry.date.formatted(date: .omitted, time: .shortened)
        if cal.isDateInToday(entry.date) { return String(localized: "Heute, \(time)") }
        if cal.isDateInYesterday(entry.date) { return String(localized: "Gestern, \(time)") }
        return entry.date.formatted(.dateTime.day().month(.wide).hour().minute())
    }

    var body: some View {
        HStack(spacing: 11) {
            Text(entry.moodValue?.emoji ?? "📝")
                .font(.title3)
                .frame(width: 38, height: 38)
                .background(Circle().fill(AppColor.mint))

            VStack(alignment: .leading, spacing: 2) {
                Text(dateText)
                    .font(.caption2)
                    .foregroundStyle(AppColor.muted)
                Text(entry.text.isEmpty ? String(localized: "Ohne Text") : entry.text)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColor.ink)
                    .lineLimit(2)
                if let trigger = entry.triggerName, !trigger.isEmpty {
                    Label(trigger, systemImage: "bolt.fill")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(AppColor.coral)
                }
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppColor.muted)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 14)
        .gainSurface(radius: 18)
        .accessibilityElement(children: .combine)
    }
}
