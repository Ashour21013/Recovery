import SwiftUI

/// Zeigt die aktuelle Streak (cleane Tage) prominent an.
/// Reine UI-Komponente – erhält bereits aufbereitete Daten.
struct StreakCardView: View {
    let streak: Streak

    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: AppSpacing.s) {
                Label {
                    Text("Aktuelle Streak")
                } icon: {
                    Image(systemName: "flame.fill")
                        .symbolEffect(.pulse, options: .repeating)
                        .accessibilityHidden(true)
                }
                .font(AppFont.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

                HStack(alignment: .firstTextBaseline, spacing: AppSpacing.s) {
                    Text("\(streak.currentDays)")
                        .font(AppFont.roundedNumber())
                        .foregroundStyle(AppColor.accent)
                        .contentTransition(.numericText(value: Double(streak.currentDays)))

                    Text(streak.currentDays == 1 ? "Tag" : "Tage")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                .animation(.smooth, value: streak.currentDays)

                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: streak.isNewRecord ? "trophy.fill" : "chart.line.uptrend.xyaxis")
                        .foregroundStyle(streak.isNewRecord ? .yellow : .secondary)
                        .contentTransition(.symbolEffect(.replace))
                        .symbolEffect(.bounce, value: streak.isNewRecord)
                        .accessibilityHidden(true)
                    Text(streak.isNewRecord
                         ? "Neuer Rekord!"
                         : "Bestwert: \(streak.bestDays) Tage")
                        .font(AppFont.footnote)
                        .foregroundStyle(.secondary)
                        .contentTransition(.numericText())
                }
                .animation(.smooth, value: streak.isNewRecord)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityDescription)
    }

    /// Zusammenhängende, natürlich vorgelesene Beschreibung für VoiceOver,
    /// statt einzelner Fragmente.
    private var accessibilityDescription: String {
        let unit = streak.currentDays == 1 ? "Tag" : "Tage"
        let base = "Aktuelle Streak: \(streak.currentDays) \(unit)."
        let record = streak.isNewRecord
            ? " Neuer Rekord!"
            : " Bestwert: \(streak.bestDays) Tage."
        return base + record
    }
}

#Preview {
    StreakCardView(
        streak: Streak(currentDays: 12, bestDays: 21, startedAt: .now)
    )
    .padding()
}
