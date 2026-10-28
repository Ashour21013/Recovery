import SwiftUI

/// Dezenter „Rückfall melden“-Link (Figma, coral).
struct RelapseButton: View {
    let action: () -> Void

    var body: some View {
        VStack(spacing: 2) {
            Button(action: action) {
                Text("Rückfall melden")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(AppColor.coral)
                    .padding(.horizontal, 18)
                    .frame(minHeight: 44)
            }
            .buttonStyle(.plain)
            .accessibilityHint("Öffnet das Formular, um einen Rückfall zu dokumentieren.")
            Text("Jeder Neustart zählt. Du bist nicht allein.")
                .font(.caption2)
                .foregroundStyle(AppColor.muted)
        }
        .frame(maxWidth: .infinity)
    }
}
