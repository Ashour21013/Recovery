import SwiftUI

/// Screen 1 – Willkommen.
struct WelcomeView: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.l) {
            Spacer()

            Image(systemName: "heart.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 96, height: 96)
                .foregroundStyle(AppColor.accent)

            VStack(spacing: AppSpacing.s) {
                Text("Willkommen bei Recovery")
                    .font(AppFont.title)
                    .multilineTextAlignment(.center)

                Text("Dein Begleiter auf dem Weg, alte Gewohnheiten hinter dir zu lassen.")
                    .font(AppFont.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            PrimaryButton(title: "Los geht's", action: onContinue)
        }
        .padding(AppSpacing.l)
    }
}

#Preview {
    WelcomeView(onContinue: {})
}
