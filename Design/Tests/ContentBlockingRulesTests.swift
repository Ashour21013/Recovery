// Eigenständige Tests für die Inhaltsschutz-Logik (ohne Test-Target).
//
// Ausführen (Top-Level-Code muss als main.swift kompiliert werden):
//   cd /Users/S43DB/Desktop/Recovery
//   mkdir -p /tmp/cbt && cp Design/Tests/ContentBlockingRulesTests.swift /tmp/cbt/main.swift
//   swiftc Recovery/Features/ContentBlocking/ContentBlockingRules.swift /tmp/cbt/main.swift -o /tmp/cbt/run && /tmp/cbt/run

import Foundation

var failures = 0
func expect(_ condition: Bool, _ message: String, line: Int = #line) {
    if condition { print("✅ \(message)") } else { failures += 1; print("❌ \(message) (Zeile \(line))") }
}

// MARK: DomainNormalizer
let cases: [(String, String?)] = [
    ("beispiel.com", "beispiel.com"),
    ("  Beispiel.COM  ", "beispiel.com"),
    ("https://www.example.com/path?q=1#x", "example.com"),
    ("http://user@sub.example.co.uk:8080/", "sub.example.co.uk"),
    ("example.com.", "example.com"),
    ("", nil),
    ("localhost", nil),
    ("exa mple.com", nil),
    ("-bad.com", nil),
    ("example.c0m", nil),
    ("example..com", nil),
]
for (input, expected) in cases {
    expect(DomainNormalizer.normalize(input) == expected,
           "normalize(\"\(input)\") == \(expected ?? "nil")")
}

// MARK: DeactivationCountdown
var countdown = DeactivationCountdown(duration: 3)
expect(!countdown.isFinished && countdown.progress == 0, "Countdown startet unvollständig")
countdown.tick(); countdown.tick()
expect(countdown.remaining == 1, "Nach 2 Ticks verbleibt 1 s")
countdown.tick(); countdown.tick()
expect(countdown.isFinished && countdown.remaining == 0, "Countdown endet bei 0 (nie negativ)")
expect(countdown.progress == 1, "Fortschritt am Ende = 1")
expect(DeactivationCountdown(duration: 0).isFinished, "Dauer 0 ist sofort beendet")

print(failures == 0 ? "\nAlle Tests bestanden." : "\n\(failures) Test(s) fehlgeschlagen.")
exit(failures == 0 ? 0 : 1)
