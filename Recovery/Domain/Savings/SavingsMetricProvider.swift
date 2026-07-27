import Foundation

/// Liefert die zu einer Sucht passenden Fortschritts-Gewinne.
///
/// Strategy-Pattern: Jede Suchtart-Kategorie (Geld, Zeit) besitzt einen
/// eigenen Provider. Das ViewModel kennt ausschließlich diese Abstraktion,
/// nie die konkreten Implementierungen (Dependency Inversion).
protocol SavingsMetricProvider {

    /// Berechnet die Gewinne für eine Sucht anhand der Streak-Dauer und der
    /// hinterlegten Nutzer-Eingaben.
    ///
    /// - Parameters:
    ///   - habitType: Die betroffene Suchtart.
    ///   - streakDays: Anzahl cleaner Tage.
    ///   - metrics: Vom Nutzer hinterlegte Eingaben (können leer sein).
    /// - Returns: Passende Gewinne. Leer, wenn keine Eingaben vorliegen.
    func gains(
        for habitType: HabitType,
        streakDays: Int,
        metrics: AddictionMetrics
    ) -> [RecoveryGain]
}
