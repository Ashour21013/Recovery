import SwiftUI

/// Wiederverwendbare, auswählbare Listenzeile (Single-Select-Optik).
/// Reine UI-Komponente ohne Geschäftslogik.
struct SelectableRow: View {
    let title: String
    let systemImage: String?
    let isSelected: Bool
    let action: () -> Void

    init(
        title: String,
        systemImage: String? = nil,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.isSelected = isSelected
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.m) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .frame(width: 24)
                }
                Text(title)
                    .font(AppFont.body)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppColor.accent)
                }
            }
            .padding(AppSpacing.m)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? AppColor.accent.opacity(0.12) : Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? AppColor.accent : .clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
    }
}
