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
    func publish(profile: RecoveryProfile, addictions: [AddictionSummary] = [], isPremium: Bool, now: Date = .now) {
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
            addictions: widgetAddictions(from: addictions, activeProfile: profile, now: now),
            quotesBySource: quotesBySource(isPremium: isPremium),
            updatedAt: now
        )
        store.save(snapshot)
    }

    // MARK: - Private

    /// Bildet die Süchte-Liste auf die geteilte Transportstruktur ab.
    ///
    /// `AddictionSummary` kennt kein Startdatum – für das Widget wird es aus
    /// der aktuellen Streak rekonstruiert (tagesgenau ausreichend, da das
    /// Widget kalendarisch weiterzählt). Für die aktive Sucht wird das exakte
    /// Startdatum des geladenen Profils verwendet.
    private func widgetAddictions(
        from summaries: [AddictionSummary],
        activeProfile: RecoveryProfile,
        now: Date
    ) -> [WidgetAddiction] {
        let calendar = Calendar.current
        return summaries.map { summary in
            let startDate: Date
            if summary.isActive {
                startDate = activeProfile.startDate
            } else {
                startDate = calendar.date(
                    byAdding: .day,
                    value: -summary.currentStreakDays,
                    to: calendar.startOfDay(for: now)
                ) ?? now
            }
            return WidgetAddiction(
                id: summary.id.uuidString,
                title: summary.title,
                systemImage: summary.habitType.iconName,
                currentStreakDays: summary.currentStreakDays,
                longestStreakDays: summary.bestStreakDays,
                startDate: startDate,
                isActive: summary.isActive
            )
        }
    }

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

    /// Baut die Sprüche je Quelle für die Quellen-Auswahl im Widget.
    ///
    /// Free-Nutzer erhalten nur die Basis-Quelle (`quotes`); Premium-Nutzer
    /// alle Quellen. Schlüssel sind die `rawValue`s, die mit
    /// `WidgetQuoteSource` übereinstimmen.
    private func quotesBySource(isPremium: Bool) -> [String: [WidgetQuote]] {
        let sources: [MotivationSource] = isPremium
            ? MotivationSource.allCases
            : [.quotes]
        var result: [String: [WidgetQuote]] = [:]
        for source in sources {
            let provider = providerFactory.provider(for: source)
            result[source.rawValue] = provider.collectItems().map {
                WidgetQuote(id: $0.id, text: $0.text, author: $0.source)
            }
        }
        return result
    }
}
