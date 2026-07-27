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
            .padding(AppSpacing.l)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(AppColor.cardBackground)
            )
    }
}
