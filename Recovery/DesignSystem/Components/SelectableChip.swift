import SwiftUI

/// Wiederverwendbarer, auswählbarer Chip (Tag-Optik).
/// Reine UI-Komponente ohne Geschäftslogik.
struct SelectableChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.xs) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.bold))
                }
                Text(title)
                    .font(.subheadline)
            }
            .padding(.horizontal, AppSpacing.m)
            .padding(.vertical, AppSpacing.s)
            .background(
                Capsule()
                    .fill(isSelected ? AppColor.accent.opacity(0.18) : Color(.secondarySystemBackground))
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? AppColor.accent : .clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .foregroundStyle(isSelected ? AppColor.accent : .primary)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#Preview {
    HStack {
        SelectableChip(title: "Stress", isSelected: true, action: {})
        SelectableChip(title: "Langeweile", isSelected: false, action: {})
    }
    .padding()
}
