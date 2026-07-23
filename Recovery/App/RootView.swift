import SwiftUI

/// Wurzel-View der App. Entscheidet über den anzuzeigenden Top-Level-Flow.
///
/// Zeigt zunächst den Onboarding-Flow. Nach dessen Abschluss wird auf das
/// Dashboard umgeschaltet. Der Zustand wird aktuell nur im Speicher gehalten
/// (noch keine Persistenz).
struct RootView: View {

    @State private var hasCompletedOnboarding = false

    var body: some View {
        if hasCompletedOnboarding {
            DashboardView()
        } else {
            OnboardingView(onComplete: { hasCompletedOnboarding = true })
        }
    }
}
