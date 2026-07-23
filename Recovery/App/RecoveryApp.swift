import SwiftUI
import SwiftData

/// App entry point. Hier werden der SwiftData `ModelContainer`
/// und der Dependency-Container aufgebaut und injiziert.
@main
struct RecoveryApp: App {

    // Zentraler Dependency-Container (Composition Root).
    private let dependencies = AppDependencies()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.dependencies, dependencies)
        }
        .modelContainer(dependencies.modelContainer)
    }
}
