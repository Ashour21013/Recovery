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

    /// Sperrt den Inhalt hinter Premium, sofern das Feature nicht freigeschaltet
    /// ist: dezenter Blur + Schloss-Overlay, Tap öffnet die Paywall. Ist das
    /// Feature freigeschaltet, wird der Inhalt unverändert dargestellt.
    ///
    /// Beispiel:
    /// ```swift
    /// StatisticsChart().premiumGated(.alleStatistiken)
    /// ```
    func premiumGated(_ feature: PremiumFeature) -> some View {
        modifier(PremiumGatedModifier(feature: feature))
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

/// Sperrt beliebige Inhalte hinter Premium: dezenter Blur + Schloss-Overlay.
/// Tap öffnet die Paywall. Freigeschaltete Features bleiben unverändert.
private struct PremiumGatedModifier: ViewModifier {
    let feature: PremiumFeature

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
                lockedContent(content)
            }
        }
        .sheet(isPresented: $isShowingPaywall) {
            PaywallView()
        }
    }

    private func lockedContent(_ content: Content) -> some View {
        content
            .blur(radius: 6)
            .disabled(true)
            .overlay {
                PremiumBadge()
                    .scaleEffect(1.2)
            }
            .contentShape(Rectangle())
            .onTapGesture { isShowingPaywall = true }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(feature.title) – Premium-Funktion")
            .accessibilityHint("Doppeltippen, um Premium freizuschalten")
            .accessibilityAddTraits(.isButton)
    }
}
