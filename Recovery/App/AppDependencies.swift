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

    init() {
        do {
            // Registrierte SwiftData-Modelle werden später ergänzt.
            let schema = Schema([])
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            self.modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("ModelContainer konnte nicht erstellt werden: \(error)")
        }
    }

    // MARK: - Factories
    // Repositories und Use Cases werden hier bereitgestellt, sobald
    // die entsprechenden Features implementiert werden.
}
