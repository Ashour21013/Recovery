import SwiftUI

/// Attraktiver Teaser für ein gesperrtes Premium-Feature.
///
/// Statt den Inhalt komplett zu verbergen, zeigt die Karte **klar sichtbar**
/// Icon, Titel und Nutzen des Features – plus ein dezentes `PremiumBadge` und
/// einen klaren Call-to-Action. Nur ein optionales Beispiel-Preview im
/// Hintergrund (Dummy-Chart/-Zahlen) ist leicht verblurrt, um den Look zu
/// vermitteln, ohne echte Nutzerdaten zu zeigen.
struct LockedFeatureCard<Preview: View>: View {

    let feature: PremiumFeature
    let onUnlock: () -> Void
    @ViewBuilder var preview: () -> Preview

    var body: some View {
        Button(action: onUnlock) {
            ZStack {
                // Dezentes, generisches Beispiel im Hintergrund.
                preview()
                    .blur(radius: 5)
                    .opacity(0.35)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)

                foreground
            }
            .frame(maxWidth: .infinity)
            .background(AppColor.cardBackground, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(alignment: .topTrailing) {
                PremiumBadge(style: .star)
                    .padding(AppSpacing.s)
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(feature.teaserTitle) – Premium-Funktion. \(feature.teaserDescription)")
        .accessibilityHint("Doppeltippen, um mit Premium freizuschalten")
        .accessibilityAddTraits(.isButton)
    }

    private var foreground: some View {
        VStack(spacing: AppSpacing.s) {
            Image(systemName: feature.systemImage)
                .font(.title)
                .foregroundStyle(AppColor.accent)
                .frame(width: 52, height: 52)
                .background(AppColor.accent.opacity(0.15), in: Circle())

            Text(feature.teaserTitle)
                .font(AppFont.headline)
                .foregroundStyle(.primary)

            Text(feature.teaserDescription)
                .font(AppFont.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Label("Mit Premium freischalten", systemImage: "lock.open.fill")
                .font(AppFont.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, AppSpacing.m)
                .padding(.vertical, AppSpacing.s)
                .background(AppColor.accent.gradient, in: Capsule())
                .padding(.top, AppSpacing.xs)
        }
        .padding(AppSpacing.l)
    }
}

/// Bequemer Initializer ohne Hintergrund-Preview.
extension LockedFeatureCard where Preview == EmptyView {
    init(feature: PremiumFeature, onUnlock: @escaping () -> Void) {
        self.init(feature: feature, onUnlock: onUnlock, preview: { EmptyView() })
    }
}

#Preview {
    VStack {
        LockedFeatureCard(feature: .alleStatistiken, onUnlock: {}) {
            SampleChartPreview()
        }
        LockedFeatureCard(feature: .recoveryGains, onUnlock: {})
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
