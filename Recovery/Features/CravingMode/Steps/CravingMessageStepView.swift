import SwiftUI

/// Wiederverwendbare Vorlage für einfache, informative Craving-Schritte
/// (Symbol, Titel, Beschreibung, optionaler Inhalt). Reine UI-Komponente.
struct CravingMessageStepView<Content: View>: View {
    let systemImage: String
    let title: String
    let message: String
    var tint: Color = AppColor.accent
    @ViewBuilder var content: () -> Content

    @State private var appeared = false

    var body: some View {
        VStack(spacing: AppSpacing.l) {
            Spacer(minLength: 0)

            Image(systemName: systemImage)
                .font(.system(size: 64))
                .foregroundStyle(tint)
                .symbolRenderingMode(.hierarchical)
                .symbolEffect(.bounce, value: appeared)
                .scaleEffect(appeared ? 1 : 0.85)
                .animation(.spring(response: 0.45, dampingFraction: 0.6), value: appeared)

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
        .onAppear { appeared = true }
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
