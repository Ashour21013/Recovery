import SwiftUI

/// Wiederverwendbarer Primär-Button des Design-Systems.
/// Reine UI-Komponente ohne Geschäftslogik.
struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.body.bold())
                .frame(maxWidth: .infinity)
                .padding(AppSpacing.m)
        }
        .buttonStyle(PressableProminentButtonStyle())
    }
}

/// Prominenter Button mit dezentem Press-Feedback (leichtes Verkleinern)
/// für ein natürliches, Apple-typisches Tippgefühl. Reine UI-Komponente.
struct PressableProminentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppColor.accent)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.smooth(duration: 0.2), value: configuration.isPressed)
    }
}
