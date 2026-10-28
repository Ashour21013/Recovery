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
        Self.applyFigmaNavigationAppearance()
    }

    /// Figma-Navigationsleiste: kräftige Titel in „Ink“, ohne Trennlinie.
    private static func applyFigmaNavigationAppearance() {
        let ink = UIColor { $0.userInterfaceStyle == .dark
            ? UIColor(red: 0.93, green: 0.95, blue: 0.95, alpha: 1)
            : UIColor(red: 0.09, green: 0.13, blue: 0.12, alpha: 1) }
        let appearance = UINavigationBar.appearance()
        appearance.largeTitleTextAttributes = [
            .foregroundColor: ink,
            .font: UIFont.systemFont(ofSize: 32, weight: .heavy)
        ]
        appearance.titleTextAttributes = [
            .foregroundColor: ink,
            .font: UIFont.systemFont(ofSize: 17, weight: .bold)
        ]
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.dependencies, dependencies)
        }
        .modelContainer(dependencies.modelContainer)
    }
}
