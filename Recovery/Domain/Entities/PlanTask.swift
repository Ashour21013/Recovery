import Foundation

/// Definition einer Aufgabe im Recovery-Plan.
///
/// Kann aus dem eingebauten Katalog (`RecoveryTaskType`) stammen oder eine
/// vom Nutzer selbst vorgeschlagene Übung sein. Reine Domain-Entität.
struct PlanTask: Identifiable, Equatable {
    /// Stabile Kennung: Roh-Wert eines `RecoveryTaskType` oder eine UUID
    /// für benutzerdefinierte Übungen.
    let id: String
    var title: String
    var subtitle: String
    var systemImage: String
    /// Ob es sich um eine selbst hinzugefügte Übung handelt.
    var isCustom: Bool

    init(id: String, title: String, subtitle: String, systemImage: String, isCustom: Bool) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.isCustom = isCustom
    }

    /// Erzeugt eine Plan-Aufgabe aus einem eingebauten Katalog-Typ.
    init(_ type: RecoveryTaskType) {
        self.id = type.rawValue
        self.title = type.title
        self.subtitle = type.subtitle
        self.systemImage = type.systemImage
        self.isCustom = false
    }

    /// Erzeugt eine neue benutzerdefinierte Übung.
    static func custom(title: String, subtitle: String, systemImage: String) -> PlanTask {
        PlanTask(
            id: UUID().uuidString,
            title: title,
            subtitle: subtitle,
            systemImage: systemImage,
            isCustom: true
        )
    }
}
