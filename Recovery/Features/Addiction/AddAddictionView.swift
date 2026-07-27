import SwiftUI

/// Schlanker Flow zum Hinzufügen einer weiteren Sucht.
///
/// Nutzt die bestehenden Design-System-Komponenten. Reine UI – meldet die
/// Auswahl über `onAdd` nach außen.
struct AddAddictionView: View {
    /// Nur Typen anzeigen, die noch nicht getrackt werden.
    let availableTypes: [HabitType]
    let onAdd: (HabitType, String, HabitFrequency?) -> Void
    let onCancel: () -> Void

    @State private var selectedType: HabitType?
    @State private var reason: String = ""
    @State private var selectedFrequency: HabitFrequency?

    private let columns = [
        GridItem(.flexible(), spacing: AppSpacing.m),
        GridItem(.flexible(), spacing: AppSpacing.m)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.l) {
                    typeSection
                    reasonSection
                    frequencySection
                }
                .padding(AppSpacing.m)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Sucht hinzufügen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Hinzufügen") {
                        if let selectedType {
                            onAdd(selectedType, reason, selectedFrequency)
                        }
                    }
                    .disabled(selectedType == nil)
                }
            }
        }
    }

    // MARK: - Abschnitte

    private var typeSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.s) {
            Text("Was möchtest du verändern?")
                .font(AppFont.headline)
            LazyVGrid(columns: columns, spacing: AppSpacing.m) {
                ForEach(availableTypes) { type in
                    typeTile(type)
                }
            }
        }
    }

    private func typeTile(_ type: HabitType) -> some View {
        let isSelected = selectedType == type
        return Button {
            withAnimation(.smooth(duration: 0.2)) { selectedType = type }
        } label: {
            VStack(spacing: AppSpacing.s) {
                Text(type.emoji)
                    .font(.system(size: 36))
                    .accessibilityHidden(true)
                Text(type.title)
                    .font(AppFont.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 110)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(isSelected ? AppColor.accent.opacity(0.14) : AppColor.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(isSelected ? AppColor.accent : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(type.title)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    private var reasonSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.s) {
            Text("Dein Warum (optional)")
                .font(AppFont.headline)
            AppTextEditor(placeholder: "Ich möchte aufhören, weil…", text: $reason)
        }
    }

    private var frequencySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.s) {
            Text("Wie oft passiert es? (optional)")
                .font(AppFont.headline)
            ForEach(HabitFrequency.allCases) { frequency in
                SelectableRow(
                    title: frequency.title,
                    systemImage: frequency.iconName,
                    isSelected: selectedFrequency == frequency,
                    action: {
                        withAnimation(.smooth) {
                            selectedFrequency = selectedFrequency == frequency ? nil : frequency
                        }
                    }
                )
            }
        }
    }
}

#Preview {
    AddAddictionView(
        availableTypes: HabitType.allCases,
        onAdd: { _, _, _ in },
        onCancel: {}
    )
}
