import SwiftUI

/// Sekundärer Button auf dem Dashboard, um einen Rückfall zu melden.
/// Bewusst zurückhaltend gestaltet (kein Notfall-Rot wie der Cravings-Button).
/// Reine UI-Komponente – meldet nur die Aktion nach außen.
struct RelapseButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("Rückfall melden")
                    .font(AppFont.subheadline.weight(.bold))
                    .foregroundStyle(AppColor.coral)
                    .frame(minHeight: 44)
                Text("Jeder Neustart zählt. Du bist nicht allein.")
                    .font(.caption2)
                    .foregroundStyle(AppColor.muted)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Rückfall melden")
        .accessibilityHint("Öffnet das Formular, um einen Rückfall zu dokumentieren.")
    }
}

#Preview {
    RelapseButton(action: {})
        .padding()
}
