import SwiftUI

/// Auswählbarer Chip im Figma-Stil (weiß mit Rahmen, ausgewählt getönt).
struct SelectableChip: View {
    let title: String
    let isSelected: Bool
    var tone: Color = AppColor.teal
    var toneSoft: Color = AppColor.mint
    let action: () -> Void

    init(title: String, isSelected: Bool, tone: Color = AppColor.teal,
         toneSoft: Color = AppColor.mint, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.tone = tone
        self.toneSoft = toneSoft
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.footnote.weight(isSelected ? .bold : .regular))
                .padding(.horizontal, 12)
                .frame(minHeight: 38)
                .background(Capsule().fill(isSelected ? toneSoft : AppColor.surface))
                .overlay(Capsule().stroke(isSelected ? tone.opacity(0.7) : AppColor.line, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .foregroundStyle(isSelected ? tone : AppColor.ink)
        .sensoryFeedback(.selection, trigger: isSelected)
        .animation(.smooth(duration: 0.2), value: isSelected)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}
