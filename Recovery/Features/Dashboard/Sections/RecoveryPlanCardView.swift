import SwiftUI

/// „Meine Aufgaben“ (Figma): Zähler-Pill, Fortschritt, abhakbare Zeilen.
struct RecoveryPlanCardView: View {
    let plan: RecoveryPlan
    let onToggle: (String) -> Void
    var onEdit: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Eyebrow("Mein heutiger Plan")
                    Text("Meine Aufgaben")
                        .font(.headline)
                        .foregroundStyle(AppColor.ink)
                }
                Spacer()
                Text("\(plan.completedCount)/\(plan.totalCount)")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(AppColor.teal)
                    .frame(minWidth: 38, minHeight: 28)
                    .background(Capsule().fill(AppColor.mint))
                    .contentTransition(.numericText(value: Double(plan.completedCount)))
            }
            .padding(.bottom, 10)

            BarProgress(fraction: plan.fraction, height: 4)
                .padding(.bottom, 6)

            ForEach(plan.tasks) { task in
                RecoveryTaskRow(task: task) { onToggle(task.id) }
            }

            Button(action: onEdit) {
                HStack {
                    Text("Aufgaben anpassen …")
                        .font(.caption)
                        .foregroundStyle(AppColor.muted)
                    Spacer()
                    Image(systemName: "plus")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(AppColor.teal))
                }
                .padding(.leading, 12)
                .padding(4)
                .background(RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(Color(light: 0xEDF5F2, dark: 0x1A3934)))
            }
            .buttonStyle(.plain)
            .padding(.top, 11)
            .accessibilityLabel("Plan anpassen")
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 17)
        .frame(maxWidth: .infinity, alignment: .leading)
        .gainSurface(radius: AppRadius.card)
        .animation(.smooth, value: plan.completedCount)
    }
}

private struct RecoveryTaskRow: View {
    let task: RecoveryTask
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 9) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(task.isCompleted ? AppColor.teal : .clear)
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(task.isCompleted ? AppColor.teal : Color(hex: 0xB9CBC6), lineWidth: 1.5)
                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                            .transition(.scale)
                    }
                }
                .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 1) {
                    Text(task.task.title)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(task.isCompleted ? AppColor.muted : AppColor.ink)
                        .strikethrough(task.isCompleted, color: AppColor.muted)
                    if !task.task.subtitle.isEmpty {
                        Text(task.task.subtitle)
                            .font(.caption2)
                            .foregroundStyle(AppColor.muted)
                    }
                }
                Spacer()
                Image(systemName: task.task.systemImage)
                    .font(.footnote)
                    .foregroundStyle(AppColor.muted.opacity(0.7))
            }
            .frame(minHeight: 46)
            .contentShape(Rectangle())
            .overlay(alignment: .bottom) { Rectangle().fill(AppColor.line).frame(height: 1) }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.success, trigger: task.isCompleted)
        .animation(.smooth(duration: 0.25), value: task.isCompleted)
        .accessibilityLabel(task.task.title)
        .accessibilityValue(task.isCompleted ? "erledigt" : "offen")
        .accessibilityAddTraits(.isButton)
    }
}
