import Foundation
import SwiftData

/// SwiftData-Persistenzmodell einer Aufgaben-Definition im Recovery-Plan
/// (Data-Schicht).
///
/// Speichert die vom Nutzer zusammengestellte Plan-Struktur (eingebaute und
/// eigene Übungen) samt Reihenfolge. Der tägliche Abhak-Zustand wird separat
/// in `PlanTaskCompletionModel` gehalten.
@Model
final class PlanTaskModel {
    /// Stabile Kennung (RawValue eines `RecoveryTaskType` oder UUID-String).
    @Attribute(.unique) var id: String
    var title: String
    var subtitle: String
    var systemImage: String
    var isCustom: Bool
    /// Sortierindex für die Anzeige-Reihenfolge.
    var order: Int
    var profile: RecoveryProfileModel?

    init(
        id: String,
        title: String,
        subtitle: String,
        systemImage: String,
        isCustom: Bool,
        order: Int
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.isCustom = isCustom
        self.order = order
    }
}
