import SwiftUI

/// Dunkle Zitat-Karte (Figma) für die tägliche Motivation.
struct MotivationCardView: View {
    let motivation: MotivationItem
    var onChangeSource: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(systemName: "sparkles")
                .font(.title2)
                .foregroundStyle(Color(hex: 0x83D3C3))

            Text("„\(motivation.text)“")
                .font(.custom("Georgia", size: 18, relativeTo: .title3))
                .lineSpacing(3)
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 12)
                .padding(.bottom, motivation.source == nil ? 16 : 6)
                .contentTransition(.opacity)

            if let source = motivation.source {
                Text("– \(source)")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.bottom, 14)
            }

            HStack {
                Label(motivation.origin.title, systemImage: motivation.origin.systemImage)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.65))
                Spacer()
                Button(action: onChangeSource) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(.white.opacity(0.1)))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Motivationsquelle ändern")
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .fill(AppColor.quoteGradient)
                .shadow(color: Color(hex: 0x1E4640, opacity: 0.1), radius: 17, y: 12)
        )
        .animation(.smooth, value: motivation.id)
        .accessibilityElement(children: .combine)
    }
}
