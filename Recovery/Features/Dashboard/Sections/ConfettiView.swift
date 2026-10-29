import SwiftUI

/// Kurzer Konfetti-Regen (~3 s), gezeichnet per Canvas. Rein dekorativ.
struct ConfettiView: View {
    private struct Piece {
        let x: Double, speed: Double, phase: Double, size: Double, spin: Double
        let color: Color
    }

    @State private var start = Date()
    private let pieces: [Piece] = {
        let colors: [Color] = [Color(hex: 0xF2CB69), Color(hex: 0xE8685A), Color(hex: 0x51A97A),
                               Color(hex: 0x5BB5E8), Color(hex: 0xF1A993)]
        return (0..<48).map { i in
            Piece(x: .random(in: 0...1), speed: .random(in: 0.35...0.7), phase: .random(in: 0...1),
                  size: .random(in: 5...9), spin: .random(in: 2...6), color: colors[i % colors.count])
        }
    }()

    var body: some View {
        TimelineView(.animation) { context in
            let t = context.date.timeIntervalSince(start)
            Canvas { ctx, size in
                for p in pieces {
                    let progress = t * p.speed - p.phase * 0.4
                    guard progress > 0, progress < 1.1 else { continue }
                    let x = p.x * size.width + sin(t * 3 + p.phase * 6) * 14
                    let y = -10 + progress * (size.height + 30)
                    var c = ctx
                    c.translateBy(x: x, y: y)
                    c.rotate(by: .radians(t * p.spin))
                    c.opacity = max(0, min(1, (1.1 - progress) * 4))
                    c.fill(Path(CGRect(x: -p.size / 2, y: -p.size / 4, width: p.size, height: p.size / 2)),
                           with: .color(p.color))
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
