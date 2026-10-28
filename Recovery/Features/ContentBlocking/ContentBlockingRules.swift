import Foundation

/// Normalisiert vom Nutzer eingegebene Domains (z. B. "https://www.Example.com/x")
/// auf die reine Host-Form ("example.com"), wie sie der Web-Filter erwartet.
///
/// Reine Logik ohne Framework-Abhängigkeiten (testbar).
enum DomainNormalizer {

    /// Liefert die normalisierte Domain oder `nil`, wenn die Eingabe keine
    /// gültige Domain ist.
    static func normalize(_ input: String) -> String? {
        var host = input
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        guard !host.isEmpty else { return nil }

        // Schema entfernen ("https://").
        if let range = host.range(of: "://") {
            host = String(host[range.upperBound...])
        }
        // Pfad, Query, Fragment entfernen.
        if let index = host.firstIndex(where: { "/?#".contains($0) }) {
            host = String(host[..<index])
        }
        // Benutzerinfo ("user@host") entfernen.
        if let at = host.lastIndex(of: "@") {
            host = String(host[host.index(after: at)...])
        }
        // Port entfernen.
        if let colon = host.firstIndex(of: ":") {
            host = String(host[..<colon])
        }
        if host.hasPrefix("www.") {
            host.removeFirst(4)
        }
        while host.hasSuffix(".") {
            host.removeLast()
        }

        let labels = host.split(separator: ".", omittingEmptySubsequences: false)
        guard labels.count >= 2 else { return nil }

        let allowed = Set("abcdefghijklmnopqrstuvwxyz0123456789-")
        for label in labels {
            guard !label.isEmpty,
                  label.count <= 63,
                  !label.hasPrefix("-"),
                  !label.hasSuffix("-"),
                  label.allSatisfy({ allowed.contains($0) }) else {
                return nil
            }
        }
        guard let tld = labels.last, tld.count >= 2, tld.allSatisfy(\.isLetter) else {
            return nil
        }
        return host
    }
}

/// Bewusste Hürde beim Deaktivieren des Schutzes: Erst nach Ablauf eines
/// Countdowns darf der Schutz abgeschaltet werden. Schützt in schwachen
/// Momenten vor impulsivem Abschalten.
///
/// Reiner Wert-Typ ohne Timer – der Takt kommt von außen (`tick()`), dadurch
/// deterministisch testbar.
struct DeactivationCountdown: Equatable {

    /// Standard-Wartezeit in Sekunden.
    nonisolated static let defaultDuration = 60

    let duration: Int
    private(set) var remaining: Int

    init(duration: Int = DeactivationCountdown.defaultDuration) {
        self.duration = max(0, duration)
        self.remaining = self.duration
    }

    /// `true`, sobald die Wartezeit abgelaufen ist.
    var isFinished: Bool { remaining == 0 }

    /// Fortschritt 0…1 für die Anzeige.
    var progress: Double {
        guard duration > 0 else { return 1 }
        return Double(duration - remaining) / Double(duration)
    }

    /// Zählt eine Sekunde herunter (nie unter 0).
    mutating func tick() {
        if remaining > 0 { remaining -= 1 }
    }
}
