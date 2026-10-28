import SwiftUI

/// Kleine, wiederverwendbare Bausteine des Figma-Designs.
struct Eyebrow: View {
    let text: String
    var color: Color = AppColor.muted

    init(_ text: String, color: Color = AppColor.muted) {
        self.text = text
        self.color = color
    }

    var body: some View {
        Text(text.uppercased())
            .font(.caption2.weight(.heavy))
            .tracking(1.35)
            .foregroundStyle(color)
    }
}

/// Quadratische Icon-Kachel (z. B. 36×36, Radius 12).
struct IconTile: View {
    let systemImage: String
    var foreground: Color = AppColor.teal
    var background: Color = AppColor.mint
    var size: CGFloat = 36

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: size * 0.45, weight: .semibold))
            .foregroundStyle(foreground)
            .frame(width: size, height: size)
            .background(RoundedRectangle(cornerRadius: size / 3, style: .continuous).fill(background))
    }
}

/// PRO-Badge in Gold.
struct ProTag: View {
    var text = "PRO"
    var body: some View {
        Text(text)
            .font(.system(size: 9, weight: .black))
            .tracking(0.8)
            .foregroundStyle(AppColor.gold)
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background(Capsule().fill(AppColor.goldSoft))
            .overlay(Capsule().stroke(Color(light: 0xF2D68E, dark: 0x65582B), lineWidth: 1))
    }
}

/// Großer, gefüllter Teal-Button (54 pt, Radius 17).
struct TealButtonStyle: ButtonStyle {
    var fill: Color = AppColor.teal
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous).fill(fill))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.smooth(duration: 0.2), value: configuration.isPressed)
    }
}

extension View {
    /// Figma-Kartenfläche: weiß, feiner Rahmen, weicher Schatten.
    func figmaCard(radius: CGFloat = AppRadius.card, padding: CGFloat = 17) -> some View {
        self.padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .gainSurface(radius: radius)
    }

    /// Hintergrund für ganze Screens im Figma-Stil.
    func figmaScreenBackground() -> some View {
        self.scrollContentBackground(.hidden)
            .background(AppColor.background.ignoresSafeArea())
            .tint(AppColor.teal)
    }
}
