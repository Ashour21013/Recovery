import SwiftUI

/// Screen 4 – Häufigkeit, mit der die Gewohnheit auftritt.
struct FrequencyView: View {
    let selected: HabitFrequency?
    let onSelect: (HabitFrequency) -> Void
    let canContinue: Bool
    let onContinue: () -> Void

    var body: some View {
        OnboardingScaffold(
            step: .frequency,
            title: "Wie oft passiert es?",
            subtitle: "Ehrlichkeit hilft dir, deinen Fortschritt realistisch einzuschätzen."
        ) {
            VStack(spacing: AppSpacing.s) {
                ForEach(HabitFrequency.allCases) { frequency in
                    SelectableRow(
                        title: frequency.title,
                        systemImage: frequency.iconName,
                        isSelected: selected == frequency,
                        action: { onSelect(frequency) }
                    )
                }
            }
        } footer: {
            PrimaryButton(title: "Weiter", action: onContinue)
                .disabled(!canContinue)
                .opacity(canContinue ? 1 : 0.5)
                .animation(.smooth, value: canContinue)
        }
    }
}

#Preview {
    NavigationStack {
        FrequencyView(selected: .daily, onSelect: { _ in }, canContinue: true, onContinue: {})
    }
}
