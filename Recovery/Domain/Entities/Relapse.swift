import Foundation

/// Ein dokumentierter Rückfall. Reine Domain-Entität ohne UI-Bezug.
struct Relapse: Equatable, Identifiable {
    let id: UUID
    var date: Date
    var note: String

    init(id: UUID = UUID(), date: Date = .now, note: String = "") {
        self.id = id
        self.date = date
        self.note = note
    }
}
