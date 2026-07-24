import Foundation
import SwiftData

/// Composition Root der App.
///
/// Verantwortlich für das Erzeugen und Verdrahten aller Abhängigkeiten
/// (SwiftData-Container, Repositories, Use Cases). Views und ViewModels
/// erzeugen niemals selbst konkrete Implementierungen, sondern erhalten
/// sie ausschließlich über diesen Container (Dependency Injection).
@Observable
final class AppDependencies {

    let modelContainer: ModelContainer

    /// Service für lokale Benachrichtigungen (App-weit geteilt).
    let notificationService: NotificationService = LocalNotificationService()

    /// Persistenz der Erinnerungs-Einstellungen.
    let reminderSettingsStore: ReminderSettingsStore = UserDefaultsReminderSettingsStore()

    /// Zähler für abgeschlossene Craving-Sessions.
    let cravingSessionCounter: CravingSessionCounter = UserDefaultsCravingSessionCounter()

    init() {
        do {
            let schema = Schema([
                RecoveryProfileModel.self,
                JournalEntryModel.self,
                TriggerModel.self,
                RelapseModel.self,
                AchievementModel.self
            ])
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            self.modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("ModelContainer konnte nicht erstellt werden: \(error)")
        }
    }

    // MARK: - Factories

    /// Erstellt das Recovery-Repository auf Basis des Main-Kontexts.
    ///
    /// Views/ViewModels erhalten ausschließlich die Protokoll-Abstraktion
    /// `RecoveryRepository`, niemals SwiftData-Typen.
    @MainActor
    func makeRecoveryRepository() -> RecoveryRepository {
        SwiftDataRecoveryRepository(context: modelContainer.mainContext)
    }

    /// Erstellt den Achievement-Service auf Basis des Main-Kontexts.
    @MainActor
    func makeAchievementService() -> AchievementService {
        SwiftDataAchievementService(context: modelContainer.mainContext)
    }
}
