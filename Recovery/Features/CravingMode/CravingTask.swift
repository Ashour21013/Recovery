import Foundation

/// Eine kleine, ablenkende Aufgabe im Craving-Modus.
///
/// Bewusst als Datenmodell mit statischem Katalog gehalten, damit später
/// leicht weitere Aufgaben ergänzt werden können (z. B. aus Remote-Config).
struct CravingTask: Identifiable, Equatable {
    let id: UUID
    let title: String
    let systemImage: String

    init(id: UUID = UUID(), title: String, systemImage: String) {
        self.id = id
        self.title = title
        self.systemImage = systemImage
    }
}

extension CravingTask {
    /// Erweiterbarer Katalog möglicher Aufgaben.
    static let catalog: [CravingTask] = [
        CravingTask(title: "20 Kniebeugen", systemImage: "figure.strengthtraining.functional"),
        CravingTask(title: "5 Minuten spazieren", systemImage: "figure.walk"),
        CravingTask(title: "10 Liegestütze", systemImage: "figure.core.training"),
        CravingTask(title: "Ein großes Glas Wasser trinken", systemImage: "drop.fill"),
        CravingTask(title: "1 Minute Dehnen", systemImage: "figure.flexibility")
    ]

    /// Wählt zufällig eine Aufgabe aus dem Katalog.
    static func random() -> CravingTask {
        catalog.randomElement() ?? catalog[0]
    }
}
