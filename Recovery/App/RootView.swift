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
    @State private var hasAcceptedDisclaimer = false

    var body: some View {
        Group {
            if isChecking {
                ProgressView()
            } else if !hasAcceptedDisclaimer {
                DisclaimerView(onAccept: {
                    dependencies.disclaimerStore.acceptDisclaimer()
                    withAnimation(.smooth(duration: 0.5)) {
                        hasAcceptedDisclaimer = true
                    }
                })
                .transition(.opacity)
            } else if hasCompletedOnboarding {
                MainTabView(onDataDeleted: {
                    withAnimation(.smooth(duration: 0.5)) {
                        hasCompletedOnboarding = false
                    }
                })
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
        .animation(.smooth(duration: 0.5), value: hasAcceptedDisclaimer)
        .task {
            hasAcceptedDisclaimer = dependencies.disclaimerStore.hasAcceptedDisclaimer
            let repository = dependencies.makeRecoveryRepository()
            let profile = try? await repository.loadProfile()
            hasCompletedOnboarding = (profile ?? nil) != nil
            isChecking = false
        }
    }
}
