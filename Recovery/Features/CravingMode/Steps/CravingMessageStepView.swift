import SwiftUI

/// Wiederverwendbare Vorlage für einfache, informative Craving-Schritte
/// (Symbol, Titel, Beschreibung, optionaler Inhalt). Reine UI-Komponente.
struct CravingMessageStepView<Content: View>: View {
    let systemImage: String
    let title: String
    let message: String
    var tint: Color = AppColor.accent
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(spacing: AppSpacing.l) {
            Spacer(minLength: 0)

            Image(systemName: systemImage)
                .font(.system(size: 64))
                .foregroundStyle(tint)
                .symbolRenderingMode(.hierarchical)

            Text(title)
                .font(AppFont.title)
                .multilineTextAlignment(.center)

            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            content()

            Spacer(minLength: 0)
        }
        .padding(AppSpacing.l)
        .frame(maxWidth: .infinity)
    }
}

extension CravingMessageStepView where Content == EmptyView {
    init(systemImage: String, title: String, message: String, tint: Color = AppColor.accent) {
        self.init(systemImage: systemImage, title: title, message: message, tint: tint) {
            EmptyView()
        }
    }
}

#Preview {
    CravingMessageStepView(
        systemImage: "hand.wave.fill",
        title: "Durchatmen",
        message: "Du hast den ersten Schritt gemacht."
    )
}
