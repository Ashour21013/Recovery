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
