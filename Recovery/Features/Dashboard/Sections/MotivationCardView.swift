import SwiftUI

/// Zeigt einen Motivationsspruch an.
/// Reine UI-Komponente ohne Geschäftslogik.
struct MotivationCardView: View {
    let quote: MotivationalQuote

    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: AppSpacing.s) {
                Image(systemName: "quote.opening")
                    .font(.title2)
                    .foregroundStyle(AppColor.accent)

                Text(quote.text)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                if let author = quote.author {
                    Text("– \(author)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    MotivationCardView(
        quote: MotivationalQuote(text: "Du bist stärker als deine Gewohnheit.")
    )
    .padding()
}
