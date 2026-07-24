import SwiftUI

/// Dashboard-Karte des täglichen Recovery-Plans.
///
/// Zeigt den Fortschritt über alle Aufgaben und listet jede Aufgabe mit einer
/// abhakbaren Checkbox. Reine UI-Komponente – meldet Umschalt-Aktionen nach
/// außen und enthält keine Geschäftslogik.
struct RecoveryPlanCardView: View {
    let plan: RecoveryPlan
    let onToggle: (RecoveryTaskType) -> Void

    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: AppSpacing.m) {
                header

                ProgressView(value: plan.fraction)
                    .tint(AppColor.accent)
                    .animation(.smooth, value: plan.fraction)

                VStack(spacing: AppSpacing.xs) {
                    ForEach(plan.tasks) { task in
                        RecoveryTaskRow(task: task) { onToggle(task.type) }
                        if task.id != plan.tasks.last?.id {
                            Divider()
                        }
                    }
                }
            }
        }
    }

    private var header: some View {
        HStack {
            Label("Dein Tagesplan", systemImage: "checklist")
                .font(.headline)
            Spacer()
            Text("\(plan.completedCount)/\(plan.totalCount)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .contentTransition(.numericText(value: Double(plan.completedCount)))
                .animation(.smooth, value: plan.completedCount)
        }
    }
}

/// Einzelne, abhakbare Aufgabenzeile.
private struct RecoveryTaskRow: View {
    let task: RecoveryTask
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: AppSpacing.m) {
                Image(systemName: task.type.systemImage)
                    .font(.body)
                    .foregroundStyle(task.isCompleted ? AppColor.accent : .secondary)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(task.type.title)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                        .strikethrough(task.isCompleted, color: .secondary)
                    Text(task.type.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(task.isCompleted ? AppColor.accent : Color(.tertiaryLabel))
                    .contentTransition(.symbolEffect(.replace))
                    .symbolEffect(.bounce, value: task.isCompleted)
            }
            .padding(.vertical, AppSpacing.xs)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.smooth(duration: 0.25), value: task.isCompleted)
        .accessibilityLabel(task.type.title)
        .accessibilityValue(task.isCompleted ? "erledigt" : "offen")
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    RecoveryPlanCardView(
        plan: RecoveryPlan(
            date: .now,
            tasks: [
                RecoveryTask(type: .journal, isCompleted: true),
                RecoveryTask(type: .meditation, isCompleted: false),
                RecoveryTask(type: .motivation, isCompleted: true),
                RecoveryTask(type: .walk, isCompleted: false),
                RecoveryTask(type: .sport, isCompleted: false)
            ]
        ),
        onToggle: { _ in }
    )
    .padding()
}
