import SwiftUI

/// Wiederverwendbarer Karten-Container mit einheitlichem Hintergrund,
/// Abrundung und Padding. Reine UI-Komponente ohne Geschäftslogik.
struct CardContainer<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(17)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                    .fill(AppColor.surface)
                    .shadow(color: Color(hex: 0x1C433E, opacity: 0.06), radius: 10, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                    .stroke(AppColor.line.opacity(0.7), lineWidth: 1)
            )
    }
}
