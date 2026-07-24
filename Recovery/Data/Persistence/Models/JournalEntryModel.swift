import Foundation
import SwiftData

/// SwiftData-Persistenzmodell eines Journal-Eintrags (Data-Schicht).
@Model
final class JournalEntryModel {
    @Attribute(.unique) var id: UUID
    var date: Date
    var text: String
    var mood: Int?
    var profile: RecoveryProfileModel?

    init(id: UUID, date: Date, text: String, mood: Int?) {
        self.id = id
        self.date = date
        self.text = text
        self.mood = mood
    }
}
