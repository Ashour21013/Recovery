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
        .buttonStyle(.borderedProminent)
    }
}
