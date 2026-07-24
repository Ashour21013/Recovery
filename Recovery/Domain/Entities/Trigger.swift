import Foundation

/// Ein Auslöser ("Trigger"), der Verlangen hervorruft. Reine Domain-Entität.
struct Trigger: Equatable, Identifiable {
    let id: UUID
    var name: String
    var note: String
    var createdAt: Date

    init(id: UUID = UUID(), name: String, note: String = "", createdAt: Date = .now) {
        self.id = id
        self.name = name
        self.note = note
        self.createdAt = createdAt
    }
}
