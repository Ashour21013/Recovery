import SwiftUI
import SwiftData
import UserNotifications

/// App entry point. Hier werden der SwiftData `ModelContainer`
/// und der Dependency-Container aufgebaut und injiziert.
@main
struct RecoveryApp: App {

    // Zentraler Dependency-Container (Composition Root).
    private let dependencies = AppDependencies()

    // Delegate für Vordergrund-Benachrichtigungen (stark referenziert halten).
    private let notificationDelegate = NotificationDelegate()

    init() {
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.dependencies, dependencies)
        }
        .modelContainer(dependencies.modelContainer)
    }
}
