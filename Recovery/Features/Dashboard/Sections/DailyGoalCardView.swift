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
                        .font(AppFont.headline)
                    Spacer()
                    if goal.isCompleted {
                        Label("Erledigt", systemImage: "checkmark.seal.fill")
                            .font(AppFont.footnote.weight(.semibold))
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
                    .font(AppFont.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityDescription)
    }

    private var accessibilityDescription: String {
        let status = goal.isCompleted ? " Erledigt." : ""
        return "\(goal.title): \(goal.completedTasks) von \(goal.totalTasks) Aufgaben abgeschlossen.\(status)"
    }
}

#Preview {
    DailyGoalCardView(
        goal: DailyGoal(title: "Heutige Ziele", completedTasks: 2, totalTasks: 3)
    )
    .padding()
}
