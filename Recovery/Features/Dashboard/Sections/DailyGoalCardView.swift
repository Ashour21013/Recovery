import SwiftUI

/// Tagesziel-Karte mit Fortschrittsanzeige der erledigten Teilaufgaben.
/// Reine UI-Komponente ohne Geschäftslogik.
struct DailyGoalCardView: View {
    let goal: DailyGoal

    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: AppSpacing.m) {
                HStack {
                    Text(goal.title)
                        .font(.headline)
                    Spacer()
                    if goal.isCompleted {
                        Label("Erledigt", systemImage: "checkmark.seal.fill")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.green)
                    }
                }

                Gauge(value: goal.fraction) {
                    Text("Tagesziel")
                } currentValueLabel: {
                    Text("\(goal.completedTasks)/\(goal.totalTasks)")
                }
                .gaugeStyle(.accessoryLinearCapacity)
                .tint(AppColor.accent)

                Text("\(goal.completedTasks) von \(goal.totalTasks) Aufgaben abgeschlossen")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    DailyGoalCardView(
        goal: DailyGoal(title: "Heutige Ziele", completedTasks: 2, totalTasks: 3)
    )
    .padding()
}
