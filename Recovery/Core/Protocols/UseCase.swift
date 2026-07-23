import Foundation

/// Basis-Protokoll für alle Use Cases (Anwendungsfälle) der Domain-Schicht.
///
/// Ein Use Case kapselt genau eine Geschäftsregel/Aktion und ist
/// unabhängig von UI und Datenquelle (Single Responsibility Principle).
protocol UseCase {
    associatedtype Input
    associatedtype Output

    func execute(_ input: Input) async throws -> Output
}

/// Bequemlichkeits-Protokoll für Use Cases ohne Eingabeparameter.
protocol ParameterlessUseCase {
    associatedtype Output

    func execute() async throws -> Output
}
