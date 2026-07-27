import WidgetKit
import AppIntents

/// Eine im Widget auswählbare Sucht (App-Intents-Entität).
///
/// Reine Anzeige-/Auswahl-Entität – die Daten stammen aus dem geteilten
/// App-Group-Speicher, es gibt keine Business-Logik im Widget.
struct AddictionAppEntity: AppEntity, Identifiable {

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Sucht"

    static var defaultQuery = AddictionEntityQuery()

    /// Entspricht der Profil-ID (als String) aus der App Group.
    let id: String
    let title: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)")
    }
}

/// Liefert die auswählbaren Süchte aus dem geteilten App-Group-Speicher.
///
/// Liest ausschließlich den `WidgetSnapshot` – keine SwiftData-/App-Logik.
struct AddictionEntityQuery: EntityQuery {

    private var store: WidgetSnapshotStore { WidgetSnapshotStore() }

    /// Auflösung konkreter IDs (z. B. beim erneuten Anzeigen der Auswahl).
    func entities(for identifiers: [String]) async throws -> [AddictionAppEntity] {
        allEntities().filter { identifiers.contains($0.id) }
    }

    /// Alle aktuell verfügbaren Süchte für die Auswahlliste.
    func suggestedEntities() async throws -> [AddictionAppEntity] {
        allEntities()
    }

    private func allEntities() -> [AddictionAppEntity] {
        let snapshot = store.load() ?? .placeholder
        return snapshot.addictions.map {
            AddictionAppEntity(id: $0.id, title: $0.title)
        }
    }
}

/// Konfigurations-Intent des Widgets: erlaubt die Auswahl der anzuzeigenden
/// Sucht (Long-Press → Widget bearbeiten).
struct SelectAddictionIntent: WidgetConfigurationIntent {

    static var title: LocalizedStringResource = "Sucht auswählen"
    static var description = IntentDescription("Wähle, welche Sucht dieses Widget anzeigt.")

    /// Optionale Auswahl – ohne Auswahl zeigt das Widget die aktive Sucht.
    @Parameter(title: "Sucht")
    var addiction: AddictionAppEntity?

    init() {}

    init(addiction: AddictionAppEntity?) {
        self.addiction = addiction
    }
}
