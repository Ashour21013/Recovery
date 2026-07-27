import SwiftUI

/// Zeigt die tägliche Motivation aus der gewählten Quelle an.
/// Reine UI-Komponente ohne Geschäftslogik.
struct MotivationCardView: View {
    let motivation: MotivationItem
    /// Öffnet die Quellen-Auswahl.
    var onChangeSource: () -> Void = {}

    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: AppSpacing.s) {
                HStack {
                    Label(motivation.origin.title, systemImage: motivation.origin.systemImage)
                        .font(AppFont.caption.weight(.semibold))
                        .foregroundStyle(AppColor.accent)
                    Spacer()
                    Button(action: onChangeSource) {
                        Image(systemName: "slider.horizontal.3")
                            .font(AppFont.subheadline.weight(.semibold))
                            .foregroundStyle(AppColor.accent)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Motivationsquelle ändern")
                }

                Text(motivation.text)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                    .contentTransition(.opacity)

                if let source = motivation.source {
                    Text("– \(source)")
                        .font(AppFont.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .animation(.smooth, value: motivation.id)
            .accessibilityElement(children: .combine)
        }
    }
}

#Preview {
    MotivationCardView(
        motivation: MotivationItem(
            id: "1",
            text: "Du bist stärker als deine Gewohnheit.",
            source: nil,
            origin: .quotes
        )
    )
    .padding()
}
