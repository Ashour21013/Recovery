import SwiftUI

/// Erstmaliger, rechtlicher Bestätigungs-Screen.
///
/// Wird beim ersten App-Start angezeigt und muss aktiv bestätigt werden.
/// Reine UI-Komponente – meldet die Bestätigung über `onAccept` nach außen;
/// die Persistenz übernimmt der Aufrufer (Composition Root / Store).
struct DisclaimerView: View {
    let onAccept: () -> Void

    @State private var appeared = false

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()

            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 72))
                .foregroundStyle(AppColor.accent.gradient)
                .symbolEffect(.bounce, value: appeared)
                .accessibilityHidden(true)

            VStack(spacing: AppSpacing.m) {
                Text("Wichtiger Hinweis")
                    .font(AppFont.title)
                    .multilineTextAlignment(.center)

                Text(DisclaimerText.long)
                    .font(AppFont.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            PrimaryButton(title: "Verstanden", action: onAccept)
        }
        .padding(AppSpacing.l)
        .opacity(appeared ? 1 : 0)
        .animation(.smooth(duration: 0.5), value: appeared)
        .onAppear { appeared = true }
    }
}

#Preview {
    DisclaimerView(onAccept: {})
}
