import Foundation

/// Basis-Protokoll für alle ViewModels (Presentation-Schicht, MVVM).
///
/// ViewModels enthalten die Präsentationslogik und den View-Zustand.
/// Sie greifen ausschließlich über Use Cases auf die Domain zu –
/// niemals direkt auf Repositories oder SwiftData.
/// Wird als `@Observable` markiert genutzt.
@MainActor
protocol ViewModel: AnyObject { }

/// Repräsentiert den generischen Ladezustand einer View,
/// um Loading-/Error-/Content-Zustände einheitlich zu behandeln.
enum ViewState<Value> {
    case idle
    case loading
    case loaded(Value)
    case failed(Error)
}
