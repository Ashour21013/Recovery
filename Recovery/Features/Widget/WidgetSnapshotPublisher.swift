import Foundation

/// Baut aus dem aktuellen Profil und Premium-Status eine `WidgetSnapshot` und
/// schreibt sie in die App Group. Einzige Stelle, die App-Domänen-Typen auf
/// die geteilte Transportstruktur abbildet (Anti-Corruption-Layer).
///
/// Keine UI, kein SwiftData – arbeitet ausschließlich mit Domain-Entities.
@MainActor
struct WidgetSnapshotPublisher {

    private let store: WidgetSnapshotStore
    private let providerFactory: MotivationProviderFactory

    init(
        store: WidgetSnapshotStore = WidgetSnapshotStore(),
        providerFactory: MotivationProviderFactory = MotivationProviderFactory()
    ) {
        self.store = store
        self.providerFactory = providerFactory
    }

    /// Erstellt und speichert den Snapshot für das gegebene Profil.
    ///
    /// - Parameters:
    ///   - profile: Aktives Recovery-Profil (liefert Streak, Sucht, Quelle).
    ///   - isPremium: Aktueller Premium-Status (für Widget-Gating und die
    ///     Auswahl der teilbaren Sprüche).
    func publish(profile: RecoveryProfile, isPremium: Bool, now: Date = .now) {
        let streak = profile.streak(now: now)
        let quotes = shareableQuotes(for: profile.motivationSource, isPremium: isPremium)

        let snapshot = WidgetSnapshot(
            currentStreakDays: streak.currentDays,
            longestStreakDays: streak.bestDays,
            addictionTitle: profile.habitType.title,
            addictionSystemImage: profile.habitType.iconName,
            startDate: profile.startDate,
            isPremium: isPremium,
            quotes: quotes,
            updatedAt: now
        )
        store.save(snapshot)
    }

    // MARK: - Private

    /// Wählt die zu teilenden Sprüche: Free-Nutzer erhalten nur die
    /// Basis-Quelle (`quotes`), Premium-Nutzer ihre gewählte (erweiterte)
    /// Quelle. So bleiben die Widget-Inhalte konsistent mit der App.
    private func shareableQuotes(
        for source: MotivationSource,
        isPremium: Bool
    ) -> [WidgetQuote] {
        let effectiveSource: MotivationSource = (isPremium && source.isPremium) ? source : .quotes
        let provider = providerFactory.provider(for: effectiveSource)
        return provider.collectItems().map {
            WidgetQuote(id: $0.id, text: $0.text, author: $0.source)
        }
    }
}
