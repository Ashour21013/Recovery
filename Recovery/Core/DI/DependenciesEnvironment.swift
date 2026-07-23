import SwiftUI

/// Stellt den `AppDependencies`-Container über die SwiftUI-Umgebung bereit,
/// sodass Views ihre ViewModels mit den benötigten Abhängigkeiten erzeugen können.
private struct DependenciesKey: EnvironmentKey {
    static let defaultValue: AppDependencies = AppDependencies()
}

extension EnvironmentValues {
    var dependencies: AppDependencies {
        get { self[DependenciesKey.self] }
        set { self[DependenciesKey.self] = newValue }
    }
}
