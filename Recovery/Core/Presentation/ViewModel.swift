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

extension ViewState: Equatable where Value: Equatable {
    static func == (lhs: ViewState<Value>, rhs: ViewState<Value>) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading):
            return true
        case let (.loaded(a), .loaded(b)):
            return a == b
        case let (.failed(a), .failed(b)):
            return (a as NSError) == (b as NSError)
        default:
            return false
        }
    }
}
