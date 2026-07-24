import Foundation
import SwiftData

/// SwiftData-Persistenzmodell eines Triggers (Data-Schicht).
@Model
final class TriggerModel {
    @Attribute(.unique) var id: UUID
    var name: String
    var note: String
    var createdAt: Date
    var profile: RecoveryProfileModel?

    init(id: UUID, name: String, note: String, createdAt: Date) {
        self.id = id
        self.name = name
        self.note = note
        self.createdAt = createdAt
    }
}
