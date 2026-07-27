import SwiftUI

/// Auswählbare Produktkarte auf der Paywall.
///
/// Zeigt Titel, Preis/Zeitraum, optionale Testphase und ein Empfehlungs-Badge.
/// Reine UI-Komponente – meldet die Auswahl nach außen.
struct ProductOptionRow: View {
    let info: ProductDisplayInfo
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.m) {
                selectionIndicator

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: AppSpacing.s) {
                        Text(info.kind.displayName)
                            .font(AppFont.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                        if let badge = info.badgeText {
                            Text(badge)
                                .font(.caption2.weight(.bold))
                                .padding(.horizontal, AppSpacing.s)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(AppColor.accent))
                                .foregroundStyle(.white)
                        }
                    }
                    if let trial = info.trialText {
                        Text(trial)
                            .font(AppFont.footnote)
                            .foregroundStyle(AppColor.accent)
                    }
                }

                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: 2) {
                    Text(info.price)
                        .font(AppFont.subheadline.weight(.bold))
                        .foregroundStyle(.primary)
                    Text(info.periodText)
                        .font(AppFont.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(AppSpacing.m)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppColor.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? AppColor.accent : .clear, lineWidth: 2)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.smooth(duration: 0.2), value: isSelected)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    private var selectionIndicator: some View {
        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
            .font(.title3)
            .foregroundStyle(isSelected ? AppColor.accent : Color(.tertiaryLabel))
            .accessibilityHidden(true)
    }

    private var accessibilityLabel: String {
        var parts = ["\(info.kind.displayName), \(info.price) \(info.periodText)"]
        if let trial = info.trialText { parts.append(trial) }
        if info.badgeText != nil { parts.append("Empfohlen") }
        return parts.joined(separator: ". ")
    }
}
