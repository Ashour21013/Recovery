import SwiftUI

/// Dashboard-Karte, die direkt zum Inhaltsschutz (Websites blockieren) führt.
struct ContentBlockingCardView: View {

    @Environment(\.dependencies) private var dependencies

    var body: some View {
        NavigationLink {
            ContentBlockingView()
        } label: {
            CardContainer {
                HStack(spacing: AppSpacing.m) {
                    Image(systemName: isEnabled ? "checkmark.shield.fill" : "hand.raised.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(isEnabled ? AppColor.success : Color.purple)
                        )
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Websites blockieren")
                            .font(AppFont.headline)
                            .foregroundStyle(.primary)
                        Text(isEnabled
                             ? "Schutz aktiv – Inhalte für Erwachsene werden blockiert."
                             : "Pornografische Inhalte auf diesem iPhone sperren.")
                            .font(AppFont.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var isEnabled: Bool {
        dependencies.contentBlockingSettingsStore.isEnabled
    }
}
