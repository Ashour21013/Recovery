import SwiftUI

/// Screen 2 – Auswahl der Gewohnheit, die geändert werden soll.
struct HabitSelectionView: View {
    let selected: HabitType?
    let onSelect: (HabitType) -> Void
    let canContinue: Bool
    let onContinue: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.l) {
            Text("Welche Gewohnheit möchtest du ändern?")
                .font(AppFont.title)

            ScrollView {
                VStack(spacing: AppSpacing.s) {
                    ForEach(HabitType.allCases) { habit in
                        SelectableRow(
                            title: habit.title,
                            systemImage: habit.iconName,
                            isSelected: selected == habit,
                            action: { onSelect(habit) }
                        )
                    }
                }
            }

            PrimaryButton(title: "Weiter", action: onContinue)
                .disabled(!canContinue)
        }
        .padding(AppSpacing.l)
        .navigationTitle("Gewohnheit")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        HabitSelectionView(selected: .smoking, onSelect: { _ in }, canContinue: true, onContinue: {})
    }
}
