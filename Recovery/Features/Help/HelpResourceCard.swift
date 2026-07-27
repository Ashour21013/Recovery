import SwiftUI

/// Wiederverwendbare Karte zur Darstellung einer einzelnen `HelpResource`.
///
/// Reine UI-Komponente. Besitzt die Ressource optional einen Weblink, wird
/// die Karte zu einem tappbaren Element, das den Link öffnet; andernfalls
/// (In-App-Ressource) kann eine optionale Aktion ausgelöst werden.
struct HelpResourceCard: View {
    let resource: HelpResource
    /// Aktion für In-App-Ressourcen ohne Weblink (optional).
    var onTap: (() -> Void)? = nil

    @Environment(\.openURL) private var openURL

    var body: some View {
        Button(action: handleTap) {
            HStack(alignment: .top, spacing: AppSpacing.m) {
                Image(systemName: resource.systemImage)
                    .font(.title3)
                    .foregroundStyle(AppColor.accent)
                    .frame(width: 32)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(resource.title)
                        .font(AppFont.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)

                    Text(resource.description)
                        .font(AppFont.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                if isInteractive {
                    Image(systemName: resource.url != nil ? "arrow.up.right.square" : "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                }
            }
            .padding(AppSpacing.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppColor.cardBackground)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isInteractive)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(resource.title). \(resource.description)")
        .accessibilityAddTraits(isInteractive ? .isButton : [])
        .accessibilityHint(resource.url != nil ? "Öffnet die Website." : "")
    }

    private var isInteractive: Bool {
        resource.url != nil || onTap != nil
    }

    private func handleTap() {
        if let url = resource.url {
            openURL(url)
        } else {
            onTap?()
        }
    }
}

#Preview {
    VStack(spacing: AppSpacing.m) {
        HelpResourceCard(
            resource: HelpResource(
                id: "1",
                title: "Sucht & Drogen – Infoportal",
                description: "Bundesweite Informationen und Beratungsangebote.",
                url: URL(string: "https://www.dhs.de"),
                systemImage: "cross.case.fill",
                category: .external(.germany)
            )
        )
        HelpResourceCard(
            resource: HelpResource(
                id: "2",
                title: "Soforthilfe bei Verlangen",
                description: "Starte den Craving-Modus und komme durch die Welle.",
                systemImage: "hand.raised.fill",
                category: .inApp
            ),
            onTap: {}
        )
    }
    .padding()
}
