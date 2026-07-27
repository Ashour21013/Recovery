import WidgetKit
import SwiftUI

/// Ein Eintrag der Widget-Timeline: der anzuzeigende Zustand zu einem
/// Zeitpunkt. Enthält den geteilten Snapshot und den tagesaktuellen Spruch.
struct RecoveryEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
    let quote: WidgetQuote?

    /// Aktuelle Streak für den angezeigten Tag (kalendarisch berechnet).
    var streakDays: Int {
        let start = Calendar.current.startOfDay(for: snapshot.startDate)
        let today = Calendar.current.startOfDay(for: date)
        let days = Calendar.current.dateComponents([.day], from: start, to: today).day ?? 0
        return max(snapshot.currentStreakDays, max(0, days))
    }
}

/// Liefert die Timeline für das Widget. Liest ausschließlich aus der App Group
/// (keine Business-Logik) und plant eine tägliche Aktualisierung zum
/// Tageswechsel, damit Streak und Motivationsspruch aktuell bleiben.
struct RecoveryTimelineProvider: TimelineProvider {

    private let store = WidgetSnapshotStore()

    func placeholder(in context: Context) -> RecoveryEntry {
        entry(from: .placeholder, date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (RecoveryEntry) -> Void) {
        let snapshot = store.load() ?? .placeholder
        completion(entry(from: snapshot, date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<RecoveryEntry>) -> Void) {
        let snapshot = store.load() ?? .placeholder
        let now = Date.now

        // Ein Eintrag für heute plus Aktualisierung zum nächsten Tagesbeginn.
        let entries = [entry(from: snapshot, date: now)]
        let timeline = Timeline(entries: entries, policy: .after(nextMidnight(after: now)))
        completion(timeline)
    }

    // MARK: - Private

    private func entry(from snapshot: WidgetSnapshot, date: Date) -> RecoveryEntry {
        RecoveryEntry(date: date, snapshot: snapshot, quote: snapshot.quote(for: date))
    }

    private func nextMidnight(after date: Date) -> Date {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        return calendar.date(byAdding: .day, value: 1, to: start) ?? date.addingTimeInterval(3600)
    }
}
