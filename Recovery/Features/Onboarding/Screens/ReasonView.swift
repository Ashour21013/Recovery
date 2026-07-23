import SwiftUI

/// Screen 3 – Grund, warum der Nutzer aufhören möchte (mehrzeiliges Textfeld).
struct ReasonView: View {
    @Binding var reason: String
    let onContinue: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.l) {
            Text("Warum möchtest du aufhören?")
                .font(AppFont.title)

            Text("Deine Motivation hilft dir in schwierigen Momenten.")
                .font(AppFont.body)
                .foregroundStyle(.secondary)

            TextEditor(text: $reason)
                .frame(minHeight: 160)
                .padding(AppSpacing.s)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                )

            Spacer()

            PrimaryButton(title: "Weiter", action: onContinue)
        }
        .padding(AppSpacing.l)
        .navigationTitle("Motivation")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ReasonView(reason: .constant(""), onContinue: {})
    }
}
