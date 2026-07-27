import SwiftUI

/// Stellt den `AppDependencies`-Container über die SwiftUI-Umgebung bereit,
/// sodass Views ihre ViewModels mit den benötigten Abhängigkeiten erzeugen können.
private struct DependenciesKey: EnvironmentKey {
    /// Fallback nur für Previews / fehlende Injection.
    ///
    /// ⚠️ Erzeugt einen eigenen `ModelContainer`. Im produktiven App-Start
    /// wird der Container immer explizit via `.environment(\.dependencies, …)`
    /// injiziert, sodass dieser Default dort nie zum Tragen kommt.
    static let defaultValue: AppDependencies = AppDependencies()
}

extension EnvironmentValues {
    var dependencies: AppDependencies {
        get { self[DependenciesKey.self] }
        set { self[DependenciesKey.self] = newValue }
    }
}
