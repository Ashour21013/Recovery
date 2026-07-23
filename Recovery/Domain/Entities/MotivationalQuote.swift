import Foundation

/// Motivationsspruch, der auf dem Dashboard angezeigt wird.
/// Reine Domain-Entität ohne UI-Bezug.
struct MotivationalQuote: Equatable, Identifiable {
    let id: UUID
    let text: String
    let author: String?

    init(id: UUID = UUID(), text: String, author: String? = nil) {
        self.id = id
        self.text = text
        self.author = author
    }
}
