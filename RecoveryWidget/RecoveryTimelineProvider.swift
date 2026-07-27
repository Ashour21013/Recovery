import WidgetKit
import SwiftUI
import AppIntents

/// Ein Eintrag der Widget-Timeline: der anzuzeigende Zustand zu einem
/// Zeitpunkt. Enthält den geteilten Snapshot, die gewählte Sucht und den
/// tagesaktuellen Spruch.
struct RecoveryEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
    /// Die konkret anzuzeigende Sucht (aufgelöst aus Konfiguration + Snapshot).
    let addiction: WidgetAddiction
    let quote: WidgetQuote?

    /// Aktuelle Streak für den angezeigten Tag (kalendarisch berechnet).
    var streakDays: Int {
        let start = Calendar.current.startOfDay(for: addiction.startDate)
        let today = Calendar.current.startOfDay(for: date)
        let days = Calendar.current.dateComponents([.day], from: start, to: today).day ?? 0
        return max(addiction.currentStreakDays, max(0, days))
    }
}

/// Liefert die Timeline für das konfigurierbare Widget. Liest ausschließlich
/// aus der App Group (keine Business-Logik) und plant eine tägliche
/// Aktualisierung zum Tageswechsel.
struct RecoveryTimelineProvider: AppIntentTimelineProvider {

    private let store = WidgetSnapshotStore()

    func placeholder(in context: Context) -> RecoveryEntry {
        entry(from: .placeholder, preferredID: nil, date: .now)
    }

    func snapshot(for configuration: SelectAddictionIntent, in context: Context) async -> RecoveryEntry {
        let snapshot = store.load() ?? .placeholder
        return entry(from: snapshot, preferredID: configuration.addiction?.id, date: .now)
    }

    func timeline(for configuration: SelectAddictionIntent, in context: Context) async -> Timeline<RecoveryEntry> {
        let snapshot = store.load() ?? .placeholder
        let now = Date.now
        let entries = [entry(from: snapshot, preferredID: configuration.addiction?.id, date: now)]
        return Timeline(entries: entries, policy: .after(nextMidnight(after: now)))
    }

    // MARK: - Private

    private func entry(from snapshot: WidgetSnapshot, preferredID: String?, date: Date) -> RecoveryEntry {
        RecoveryEntry(
            date: date,
            snapshot: snapshot,
            addiction: snapshot.resolvedAddiction(preferredID: preferredID),
            quote: snapshot.quote(for: date)
        )
    }

    private func nextMidnight(after date: Date) -> Date {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        return calendar.date(byAdding: .day, value: 1, to: start) ?? date.addingTimeInterval(3600)
    }
}
