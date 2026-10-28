import SwiftUI

/// Vorlage für Craving-Schritte im Figma-Stil: ruhiger Orb, Eyebrow,
/// großer Titel, Text und optionaler Inhalt – auf dunklem Hintergrund.
struct CravingMessageStepView<Content: View>: View {
    let systemImage: String
    var eyebrow: String = "DU BIST NICHT ALLEIN"
    let title: String
    let message: String
    var isSuccess: Bool = false
    @ViewBuilder var content: () -> Content

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            Image(systemName: systemImage)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(Color(hex: 0x9CE2D3))
                .frame(width: 86, height: 86)
                .background(Circle().fill(Color(hex: 0x79C9B9, opacity: isSuccess ? 0.22 : 0.12)))
                .background(Circle().fill(Color(hex: 0x79C9B9, opacity: 0.05)).padding(-15))
                .scaleEffect(appeared ? 1 : 0.8)
                .symbolEffect(.bounce, value: appeared)
                .padding(.bottom, 36)
                .accessibilityHidden(true)
            Text(eyebrow)
                .font(.caption2.weight(.heavy))
                .tracking(1.35)
                .foregroundStyle(.white.opacity(0.6))
            Text(title)
                .font(.system(size: 31, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.vertical, 10)
                .frame(maxWidth: 320)
            Text(message)
                .font(.body)
                .lineSpacing(4)
                .foregroundStyle(.white.opacity(0.72))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 310)
            content()
                .padding(.top, AppSpacing.l)
            Spacer(minLength: 0)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 22)
        .padding(.bottom, 30)
        .frame(maxWidth: .infinity)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { appeared = true }
        }
    }
}

extension CravingMessageStepView where Content == EmptyView {
    init(systemImage: String, eyebrow: String = "DU BIST NICHT ALLEIN",
         title: String, message: String, isSuccess: Bool = false) {
        self.init(systemImage: systemImage, eyebrow: eyebrow, title: title,
                  message: message, isSuccess: isSuccess) { EmptyView() }
    }
}

/// Glasige Zitat-Box für Affirmation / persönliches Warum.
struct CravingQuoteBox: View {
    let text: String

    var body: some View {
        Text("„\(text)“")
            .font(.custom("Georgia", size: 19, relativeTo: .title3))
            .multilineTextAlignment(.center)
            .foregroundStyle(.white)
            .padding(AppSpacing.l)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(.white.opacity(0.08)))
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(.white.opacity(0.12)))
    }
}
