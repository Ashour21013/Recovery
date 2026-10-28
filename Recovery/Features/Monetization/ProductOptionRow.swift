import SwiftUI

/// Tarif-Karte (Figma): Radio, Name + Unterzeile, Badge und Preis rechts.
struct ProductOptionRow: View {
    let info: ProductDisplayInfo
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Circle()
                    .strokeBorder(isSelected ? AppColor.teal : Color(hex: 0xBBC9C6), lineWidth: isSelected ? 5 : 2)
                    .frame(width: 19, height: 19)

                VStack(alignment: .leading, spacing: 2) {
                    Text(info.kind.displayName)
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(AppColor.ink)
                    Text(info.trialText ?? info.periodText)
                        .font(.caption2)
                        .foregroundStyle(AppColor.muted)
                }

                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: 3) {
                    if let badge = info.badgeText {
                        Text(badge.uppercased())
                            .font(.system(size: 8, weight: .black))
                            .foregroundStyle(Color(hex: 0x42824C))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 3)
                            .background(RoundedRectangle(cornerRadius: 5).fill(Color(light: 0xE4F4E7, dark: 0x1F3A26)))
                    }
                    Text(info.price)
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(AppColor.ink)
                }
            }
            .padding(.horizontal, 11)
            .frame(minHeight: 62)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? Color(light: 0xF2FAF7, dark: 0x1C3D37) : AppColor.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? AppColor.teal : AppColor.line, lineWidth: isSelected ? 2 : 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
        .animation(.smooth(duration: 0.2), value: isSelected)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    private var accessibilityLabel: String {
        var parts = ["\(info.kind.displayName), \(info.price) \(info.periodText)"]
        if let trial = info.trialText { parts.append(trial) }
        if info.badgeText != nil { parts.append("Empfohlen") }
        return parts.joined(separator: ". ")
    }
}
