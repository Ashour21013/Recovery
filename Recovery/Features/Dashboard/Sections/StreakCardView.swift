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
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

                HStack(alignment: .firstTextBaseline, spacing: AppSpacing.s) {
                    Text("\(streak.currentDays)")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
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
                    Text(streak.isNewRecord
                         ? "Neuer Rekord!"
                         : "Bestwert: \(streak.bestDays) Tage")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .contentTransition(.numericText())
                }
                .animation(.smooth, value: streak.isNewRecord)
            }
        }
    }
}

#Preview {
    StreakCardView(
        streak: Streak(currentDays: 12, bestDays: 21, startedAt: .now)
    )
    .padding()
}
