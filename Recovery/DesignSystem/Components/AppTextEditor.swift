import SwiftUI

/// Wiederverwendbares mehrzeiliges Textfeld mit Platzhalter und
/// einheitlichem Design-System-Look. Reine UI-Komponente.
struct AppTextEditor: View {
    let placeholder: String
    @Binding var text: String
    var minHeight: CGFloat = 120

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, AppSpacing.m)
                    .padding(.vertical, AppSpacing.m + 2)
                    .allowsHitTesting(false)
            }

            TextEditor(text: $text)
                .scrollContentBackground(.hidden)
                .padding(AppSpacing.s)
                .frame(minHeight: minHeight)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    AppTextEditor(placeholder: "Schreib etwas…", text: .constant(""))
        .padding()
}
