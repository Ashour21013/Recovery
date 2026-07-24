import SwiftUI

/// Screen 2 – Auswahl der Gewohnheit, die geändert werden soll.
///
/// Zeigt die Gewohnheiten als illustrierte Kacheln (Emoji + Titel) in einem
/// Raster. Die Auswahl wird weich animiert. Reine UI-Komponente.
struct HabitSelectionView: View {
    let selected: HabitType?
    let onSelect: (HabitType) -> Void
    let canContinue: Bool
    let onContinue: () -> Void

    private let columns = [
        GridItem(.flexible(), spacing: AppSpacing.m),
        GridItem(.flexible(), spacing: AppSpacing.m)
    ]

    var body: some View {
        OnboardingScaffold(
            step: .habitSelection,
            title: "Was möchtest du verändern?",
            subtitle: "Wähle die Gewohnheit, die du hinter dir lassen willst."
        ) {
            ScrollView {
                LazyVGrid(columns: columns, spacing: AppSpacing.m) {
                    ForEach(HabitType.allCases) { habit in
                        HabitTile(
                            habit: habit,
                            isSelected: selected == habit,
                            action: { onSelect(habit) }
                        )
                    }
                }
                .padding(.vertical, AppSpacing.xs)
            }
        } footer: {
            PrimaryButton(title: "Weiter", action: onContinue)
                .disabled(!canContinue)
                .opacity(canContinue ? 1 : 0.5)
                .animation(.smooth, value: canContinue)
        }
    }
}

/// Illustrierte, auswählbare Kachel für eine Gewohnheit.
private struct HabitTile: View {
    let habit: HabitType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.s) {
                Text(habit.emoji)
                    .font(.system(size: 40))
                    .scaleEffect(isSelected ? 1.1 : 1)

                Text(habit.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                Text(habit.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .padding(AppSpacing.s)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(isSelected ? AppColor.accent.opacity(0.14) : Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(isSelected ? AppColor.accent : .clear, lineWidth: 2)
            )
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppColor.accent)
                        .padding(AppSpacing.s)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .buttonStyle(.plain)
        .animation(.smooth(duration: 0.25), value: isSelected)
        .accessibilityLabel(habit.title)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#Preview {
    NavigationStack {
        HabitSelectionView(selected: .smoking, onSelect: { _ in }, canContinue: true, onContinue: {})
    }
}
