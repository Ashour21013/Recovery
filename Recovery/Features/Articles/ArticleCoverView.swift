import SwiftUI

/// Prozedural gezeichnetes Cover – jeder Artikel hat durch Motiv, Palette und Seed ein eigenes Bild.
struct ArticleCoverView: View {
    let theme: ArticleTheme

    var body: some View {
        Canvas { ctx, size in
            var rng = SeededGenerator(seed: theme.seed)
            let rect = CGRect(origin: .zero, size: size)
            ctx.fill(Path(rect), with: .linearGradient(
                Gradient(colors: [theme.light, theme.mid]),
                startPoint: .zero, endPoint: CGPoint(x: size.width, y: size.height)))

            switch theme.style {
            case 0: waves(&ctx, size, &rng)
            case 1: rings(&ctx, size, &rng)
            case 2: dunes(&ctx, size, &rng)
            case 3: blobs(&ctx, size, &rng)
            case 4: rays(&ctx, size, &rng)
            case 5: dots(&ctx, size, &rng)
            case 6: arches(&ctx, size, &rng)
            case 7: shards(&ctx, size, &rng)
            case 8: petals(&ctx, size, &rng)
            default: cards(&ctx, size, &rng)
            }
        }
        .accessibilityHidden(true)
    }

    private func shade(_ t: Double) -> Color {
        t < 0.5 ? theme.light.mix(with: theme.mid, by: t * 2) : theme.mid.mix(with: theme.dark, by: (t - 0.5) * 2)
    }

    // Gerissene Papier-Wellen
    private func waves(_ ctx: inout GraphicsContext, _ s: CGSize, _ rng: inout SeededGenerator) {
        let layers = 6
        for i in 0..<layers {
            let base = s.height * (0.2 + 0.14 * Double(i))
            let amp = Double.random(in: 10...28, using: &rng)
            let freq = Double.random(in: 1.2...2.6, using: &rng)
            let phase = Double.random(in: 0...6, using: &rng)
            var p = Path()
            p.move(to: CGPoint(x: 0, y: s.height))
            var x = 0.0
            while x <= s.width + 6 {
                let y = base + sin(x / s.width * .pi * freq + phase) * amp + Double.random(in: -1.6...1.6, using: &rng)
                p.addLine(to: CGPoint(x: x, y: y))
                x += 6
            }
            p.addLine(to: CGPoint(x: s.width, y: s.height))
            p.closeSubpath()
            ctx.fill(p, with: .color(shade(Double(i) / Double(layers - 1))))
        }
    }

    // Konzentrische Ringe
    private func rings(_ ctx: inout GraphicsContext, _ s: CGSize, _ rng: inout SeededGenerator) {
        let c = CGPoint(x: s.width * Double.random(in: 0.55...0.85, using: &rng), y: s.height * Double.random(in: 0.3...0.6, using: &rng))
        let maxR = hypot(s.width, s.height)
        for i in stride(from: 9, through: 0, by: -1) {
            let r = maxR * Double(i + 1) / 10 * 0.8
            ctx.fill(Path(ellipseIn: CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2)),
                     with: .color(shade(1 - Double(i) / 9)))
        }
        ctx.fill(Path(ellipseIn: CGRect(x: c.x - 16, y: c.y - 16, width: 32, height: 32)), with: .color(theme.light))
    }

    // Hügel mit Sonne
    private func dunes(_ ctx: inout GraphicsContext, _ s: CGSize, _ rng: inout SeededGenerator) {
        let sun = CGRect(x: s.width * Double.random(in: 0.15...0.7, using: &rng), y: s.height * 0.12, width: s.height * 0.3, height: s.height * 0.3)
        ctx.fill(Path(ellipseIn: sun), with: .color(.white.opacity(0.75)))
        for i in 0..<4 {
            let base = s.height * (0.45 + 0.15 * Double(i))
            let off = Double.random(in: -s.width...s.width, using: &rng) * 0.3
            var p = Path()
            p.move(to: CGPoint(x: 0, y: s.height))
            p.addLine(to: CGPoint(x: 0, y: base))
            p.addCurve(to: CGPoint(x: s.width, y: base + 10),
                       control1: CGPoint(x: s.width * 0.3 + off, y: base - s.height * 0.3),
                       control2: CGPoint(x: s.width * 0.7 + off, y: base + s.height * 0.12))
            p.addLine(to: CGPoint(x: s.width, y: s.height))
            p.closeSubpath()
            ctx.fill(p, with: .color(shade(0.35 + Double(i) * 0.22)))
        }
    }

    // Weiche Blobs
    private func blobs(_ ctx: inout GraphicsContext, _ s: CGSize, _ rng: inout SeededGenerator) {
        ctx.addFilter(.blur(radius: 18))
        for i in 0..<7 {
            let r = Double.random(in: s.height * 0.2...s.height * 0.5, using: &rng)
            let c = CGPoint(x: Double.random(in: 0...s.width, using: &rng), y: Double.random(in: 0...s.height, using: &rng))
            ctx.fill(Path(ellipseIn: CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2)),
                     with: .color(shade(Double(i % 4) / 3).opacity(0.8)))
        }
    }

    // Strahlen
    private func rays(_ ctx: inout GraphicsContext, _ s: CGSize, _ rng: inout SeededGenerator) {
        let origin = CGPoint(x: s.width * Double.random(in: 0.7...1.0, using: &rng), y: s.height * Double.random(in: 0...0.25, using: &rng))
        let n = 16
        let start = Double.random(in: 0...(.pi / 6), using: &rng)
        for i in 0..<n where i.isMultiple(of: 2) {
            let a1 = start + .pi * 0.5 + Double(i) / Double(n) * .pi * 0.75
            let a2 = start + .pi * 0.5 + Double(i + 1) / Double(n) * .pi * 0.75
            let r = hypot(s.width, s.height) * 1.4
            var p = Path()
            p.move(to: origin)
            p.addLine(to: CGPoint(x: origin.x + cos(a1) * r, y: origin.y + sin(a1) * r))
            p.addLine(to: CGPoint(x: origin.x + cos(a2) * r, y: origin.y + sin(a2) * r))
            p.closeSubpath()
            ctx.fill(p, with: .color(.white.opacity(0.22)))
        }
        ctx.fill(Path(ellipseIn: CGRect(x: origin.x - 34, y: origin.y - 34, width: 68, height: 68)), with: .color(theme.light))
    }

    // Halbton-Raster
    private func dots(_ ctx: inout GraphicsContext, _ s: CGSize, _ rng: inout SeededGenerator) {
        ctx.fill(Path(CGRect(origin: .zero, size: s)), with: .color(theme.dark.opacity(0.9)))
        let step = 16.0
        let focus = CGPoint(x: s.width * Double.random(in: 0.2...0.9, using: &rng), y: s.height * Double.random(in: 0.2...0.8, using: &rng))
        let maxD = hypot(s.width, s.height) * 0.7
        for gx in stride(from: 8.0, to: s.width, by: step) {
            for gy in stride(from: 8.0, to: s.height, by: step) {
                let d = hypot(gx - focus.x, gy - focus.y) / maxD
                let r = max(0.8, (1 - min(1, d)) * 7.2)
                ctx.fill(Path(ellipseIn: CGRect(x: gx - r, y: gy - r, width: r * 2, height: r * 2)),
                         with: .color(shade(1 - min(1, d)).mix(with: .white, by: 0.2)))
            }
        }
    }

    // Verschachtelte Bögen
    private func arches(_ ctx: inout GraphicsContext, _ s: CGSize, _ rng: inout SeededGenerator) {
        ctx.fill(Path(CGRect(origin: .zero, size: s)), with: .color(theme.light))
        let cx = s.width * Double.random(in: 0.35...0.65, using: &rng)
        let n = 6
        for i in 0..<n {
            let w = s.width * (0.95 - Double(i) * 0.14)
            let rect = CGRect(x: cx - w / 2, y: s.height * 0.15 + Double(i) * 16, width: w, height: s.height * 2)
            ctx.fill(Path(roundedRect: rect, cornerSize: CGSize(width: w / 2, height: w / 2)),
                     with: .color(shade(Double(i) / Double(n - 1))))
        }
    }

    // Dreiecke / Splitter
    private func shards(_ ctx: inout GraphicsContext, _ s: CGSize, _ rng: inout SeededGenerator) {
        for i in 0..<12 {
            let a = CGPoint(x: Double.random(in: -20...s.width, using: &rng), y: Double.random(in: -20...s.height, using: &rng))
            let size = Double.random(in: 60...170, using: &rng)
            var p = Path()
            p.move(to: a)
            p.addLine(to: CGPoint(x: a.x + size, y: a.y + Double.random(in: -size * 0.4...size * 0.6, using: &rng)))
            p.addLine(to: CGPoint(x: a.x + Double.random(in: -size * 0.3...size * 0.5, using: &rng), y: a.y + size))
            p.closeSubpath()
            ctx.fill(p, with: .color(shade(Double(i % 5) / 4).opacity(0.85)))
        }
    }

    // Blütenblätter
    private func petals(_ ctx: inout GraphicsContext, _ s: CGSize, _ rng: inout SeededGenerator) {
        ctx.fill(Path(CGRect(origin: .zero, size: s)), with: .color(theme.dark.opacity(0.85)))
        let c = CGPoint(x: s.width * Double.random(in: 0.45...0.75, using: &rng), y: s.height * 0.55)
        let n = 12
        let len = s.height * 0.75
        for ring in 0..<2 {
            for i in 0..<n {
                let a = Double(i) / Double(n) * .pi * 2 + Double(ring) * .pi / Double(n)
                var t = ctx
                t.translateBy(x: c.x, y: c.y)
                t.rotate(by: .radians(a))
                let l = len * (ring == 0 ? 1 : 0.62)
                t.fill(Path(ellipseIn: CGRect(x: -l * 0.13, y: -l, width: l * 0.26, height: l)),
                       with: .color(shade(ring == 0 ? 0.55 : 0.2).opacity(0.9)))
            }
        }
        ctx.fill(Path(ellipseIn: CGRect(x: c.x - 14, y: c.y - 14, width: 28, height: 28)), with: .color(.white.opacity(0.9)))
    }

    // Gekippte Karten
    private func cards(_ ctx: inout GraphicsContext, _ s: CGSize, _ rng: inout SeededGenerator) {
        for i in 0..<5 {
            var t = ctx
            t.translateBy(x: s.width * (0.2 + 0.15 * Double(i)), y: s.height * 0.5)
            t.rotate(by: .degrees(-18 + Double(i) * 9 + Double.random(in: -4...4, using: &rng)))
            let w = s.height * 0.6, h = s.height * 0.95
            t.fill(Path(roundedRect: CGRect(x: -w / 2, y: -h / 2, width: w, height: h), cornerRadius: 18),
                   with: .color(shade(Double(i) / 4)))
            t.stroke(Path(roundedRect: CGRect(x: -w / 2, y: -h / 2, width: w, height: h), cornerRadius: 18),
                     with: .color(.white.opacity(0.35)), lineWidth: 1.5)
        }
    }
}

private extension Color {
    func mix(with other: Color, by amount: Double) -> Color {
        let a = UIColor(self), b = UIColor(other)
        var (r1, g1, b1, a1) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))
        var (r2, g2, b2, a2) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))
        a.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        b.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        let t = CGFloat(min(1, max(0, amount)))
        return Color(red: r1 + (r2 - r1) * t, green: g1 + (g2 - g1) * t, blue: b1 + (b2 - b1) * t)
    }
}
