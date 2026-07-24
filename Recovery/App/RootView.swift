import SwiftUI

/// Wurzel-View der App. Entscheidet über den anzuzeigenden Top-Level-Flow.
///
/// Prüft beim Start über das Repository, ob bereits ein Recovery-Profil
/// existiert. Falls ja, wird direkt das Dashboard gezeigt, andernfalls der
/// Onboarding-Flow. Die View greift dabei nicht direkt auf SwiftData zu,
/// sondern nutzt die Repository-Abstraktion.
struct RootView: View {

    @Environment(\.dependencies) private var dependencies
    @State private var hasCompletedOnboarding = false
    @State private var isChecking = true

    var body: some View {
        Group {
            if isChecking {
                ProgressView()
            } else if hasCompletedOnboarding {
                MainTabView()
                    .transition(.opacity)
            } else {
                OnboardingView(onComplete: {
                    withAnimation(.smooth(duration: 0.5)) {
                        hasCompletedOnboarding = true
                    }
                })
                .transition(.opacity)
            }
        }
        .animation(.smooth(duration: 0.5), value: hasCompletedOnboarding)
        .task {
            let repository = dependencies.makeRecoveryRepository()
            let profile = try? await repository.loadProfile()
            hasCompletedOnboarding = (profile ?? nil) != nil
            isChecking = false
        }
    }
}
