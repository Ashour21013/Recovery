import SwiftUI

/// Wiederverwendbare Werkzeuge, um Inhalte hinter Premium zu sperren
/// („Feature-Gating"). Zentralisiert die Entitlement-Prüfung, damit einzelne
/// Features nur eine Zeile benötigen.
extension View {

    /// Zeigt bei fehlendem Premium-Zugriff automatisch die Paywall an, wenn der
    /// gebundene Auslöser aktiv wird.
    ///
    /// Beispiel:
    /// ```swift
    /// .premiumGate(isActive: $showPaywall)
    /// ```
    func premiumGate(isActive: Binding<Bool>) -> some View {
        modifier(PremiumGateModifier(isActive: isActive))
    }

    /// Ersetzt den Inhalt bei fehlendem Zugriff durch einen attraktiven Teaser
    /// (`LockedFeatureCard`) mit Icon, Titel, Nutzen und Call-to-Action. Ist das
    /// Feature freigeschaltet, wird der echte Inhalt unverändert dargestellt.
    ///
    /// Beispiel:
    /// ```swift
    /// StatisticsChart().premiumGated(.alleStatistiken)
    /// ```
    func premiumGated(_ feature: PremiumFeature) -> some View {
        modifier(PremiumGatedModifier(feature: feature, preview: { EmptyView() }))
    }

    /// Wie `premiumGated(_:)`, zeigt aber zusätzlich ein generisches
    /// Beispiel-Preview (Dummy-Chart/-Zahlen) dezent im Hintergrund des Teasers.
    func premiumGated<Preview: View>(
        _ feature: PremiumFeature,
        @ViewBuilder preview: @escaping () -> Preview
    ) -> some View {
        modifier(PremiumGatedModifier(feature: feature, preview: preview))
    }
}

/// Präsentiert die Paywall als Sheet – aber nur, wenn der Nutzer (noch) kein
/// Premium besitzt. Ist bereits Premium aktiv, wird das Sheet nicht gezeigt.
private struct PremiumGateModifier: ViewModifier {
    @Binding var isActive: Bool
    @Environment(\.dependencies) private var dependencies

    func body(content: Content) -> some View {
        content.sheet(isPresented: shouldPresent) {
            PaywallView()
        }
    }

    /// Nur präsentieren, wenn ausgelöst UND (noch) kein Premium vorhanden.
    private var shouldPresent: Binding<Bool> {
        Binding(
            get: { isActive && !dependencies.subscriptionService.entitlementStatus.isPremium },
            set: { isActive = $0 }
        )
    }
}

/// Kleiner, wiederverwendbarer Hinweis-Badge für gesperrte Premium-Features.
struct PremiumLockBadge: View {
    var body: some View {
        Label("Premium", systemImage: "lock.fill")
            .font(.caption2.weight(.bold))
            .padding(.horizontal, AppSpacing.s)
            .padding(.vertical, 3)
            .background(Capsule().fill(AppColor.accent.opacity(0.15)))
            .foregroundStyle(AppColor.accent)
            .accessibilityLabel("Premium-Funktion")
    }
}

/// Kompakte Schloss-/Stern-Kennzeichnung für gesperrte Features.
///
/// Kann inline (z. B. neben Titeln) oder als Overlay verwendet werden.
struct PremiumBadge: View {
    /// Symbol: Schloss (Standard) oder Stern.
    enum Style { case lock, star }
    var style: Style = .lock

    var body: some View {
        Image(systemName: style == .lock ? "lock.fill" : "star.fill")
            .font(.caption.weight(.bold))
            .foregroundStyle(.white)
            .padding(6)
            .background(AppColor.accent.gradient, in: Circle())
            .accessibilityLabel("Premium-Funktion")
    }
}

/// Ersetzt gesperrte Inhalte durch einen attraktiven Teaser
/// (`LockedFeatureCard`). Der echte Inhalt bleibt für Premium unverändert.
private struct PremiumGatedModifier<Preview: View>: ViewModifier {
    let feature: PremiumFeature
    @ViewBuilder let preview: () -> Preview

    @Environment(\.dependencies) private var dependencies
    @State private var isShowingPaywall = false

    private var isUnlocked: Bool {
        dependencies.featureAccess.isUnlocked(feature)
    }

    func body(content: Content) -> some View {
        Group {
            if isUnlocked {
                content
            } else {
                LockedFeatureCard(
                    feature: feature,
                    onUnlock: { isShowingPaywall = true },
                    preview: preview
                )
            }
        }
        .sheet(isPresented: $isShowingPaywall) {
            PaywallView()
        }
    }
}
