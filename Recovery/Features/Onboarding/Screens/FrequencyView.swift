import SwiftUI

/// Screen 4 – Häufigkeit, mit der die Gewohnheit auftritt.
struct FrequencyView: View {
    let selected: HabitFrequency?
    let onSelect: (HabitFrequency) -> Void
    let canContinue: Bool
    let onContinue: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.l) {
            Text("Wie häufig tritt die Gewohnheit auf?")
                .font(AppFont.title)

            VStack(spacing: AppSpacing.s) {
                ForEach(HabitFrequency.allCases) { frequency in
                    SelectableRow(
                        title: frequency.title,
                        isSelected: selected == frequency,
                        action: { onSelect(frequency) }
                    )
                }
            }

            Spacer()

            PrimaryButton(title: "Weiter", action: onContinue)
                .disabled(!canContinue)
        }
        .padding(AppSpacing.l)
        .navigationTitle("Häufigkeit")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        FrequencyView(selected: .daily, onSelect: { _ in }, canContinue: true, onContinue: {})
    }
}
