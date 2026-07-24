import Foundation
import SwiftData

/// SwiftData-Persistenzmodell eines Rückfalls (Data-Schicht).
@Model
final class RelapseModel {
    @Attribute(.unique) var id: UUID
    var date: Date
    var note: String
    var profile: RecoveryProfileModel?

    init(id: UUID, date: Date, note: String) {
        self.id = id
        self.date = date
        self.note = note
    }
}
