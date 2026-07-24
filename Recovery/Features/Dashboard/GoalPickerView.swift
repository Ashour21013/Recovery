import SwiftUI

/// Sheet zum Auswählen eines Ziels. Reine UI – meldet die Auswahl nach außen.
struct GoalPickerView: View {
    let currentGoal: RecoveryGoal?
    let currentDays: Int
    let onSelect: (RecoveryGoal) -> Void
    let onRemove: () -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(RecoveryGoal.allCases) { goal in
                        Button {
                            onSelect(goal)
                        } label: {
                            row(for: goal)
                        }
                        .buttonStyle(.plain)
                    }
                } footer: {
                    Text("Dein Fortschritt basiert auf deiner aktuellen Streak.")
                }

                if currentGoal != nil {
                    Section {
                        Button("Ziel entfernen", role: .destructive, action: onRemove)
                    }
                }
            }
            .navigationTitle("Ziel wählen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen", action: onCancel)
                }
            }
        }
    }

    private func row(for goal: RecoveryGoal) -> some View {
        HStack(spacing: AppSpacing.m) {
            Image(systemName: goal.systemImage)
                .foregroundStyle(AppColor.accent)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(goal.title)
                    .font(.body.weight(.medium))
                if goal.isAchieved(currentDays: currentDays) {
                    Text("Bereits erreicht")
                        .font(.caption)
                        .foregroundStyle(.green)
                } else {
                    Text("Noch \(goal.remainingDays(currentDays: currentDays)) Tage")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if currentGoal == goal {
                Image(systemName: "checkmark")
                    .foregroundStyle(AppColor.accent)
            }
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    GoalPickerView(
        currentGoal: .month,
        currentDays: 12,
        onSelect: { _ in },
        onRemove: {},
        onCancel: {}
    )
}
