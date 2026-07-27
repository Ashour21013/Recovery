import SwiftUI

/// Sekundärer Button auf dem Dashboard, um einen Rückfall zu melden.
/// Bewusst zurückhaltend gestaltet (kein Notfall-Rot wie der Cravings-Button).
/// Reine UI-Komponente – meldet nur die Aktion nach außen.
struct RelapseButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.s) {
                Image(systemName: "arrow.uturn.backward.circle")
                Text("Rückfall melden")
                    .font(AppFont.subheadline.weight(.medium))
            }
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .padding(AppSpacing.m)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color(.separator), lineWidth: 1)
            )
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
