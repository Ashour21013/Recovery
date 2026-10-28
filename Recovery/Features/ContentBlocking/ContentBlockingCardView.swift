import SwiftUI

/// Dashboard-Karte, die direkt zum Inhaltsschutz (Websites blockieren) führt.
struct ContentBlockingCardView: View {

    @Environment(\.dependencies) private var dependencies

    var body: some View {
        NavigationLink {
            ContentBlockingView()
        } label: {
            HStack(spacing: 11) {
                Image(systemName: isEnabled ? "checkmark" : "shield")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(isEnabled ? AppColor.green : AppColor.purple)
                    .frame(width: 42, height: 42)
                    .background(
                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                            .fill(isEnabled ? AppColor.greenSoft : AppColor.purpleSoft)
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text("Websites blockieren")
                        .font(AppFont.subheadline.weight(.semibold))
                        .foregroundStyle(AppColor.ink)
                    Text(isEnabled
                         ? String(localized: "Schutz aktiv – Inhalte für Erwachsene werden blockiert.")
                         : String(localized: "Pornografische Inhalte auf diesem iPhone sperren."))
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.muted)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(AppColor.muted)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(minHeight: 66)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppColor.surface)
                    .shadow(color: Color(hex: 0x1C433E, opacity: 0.06), radius: 9, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppColor.line, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var isEnabled: Bool {
        dependencies.contentBlockingSettingsStore.isEnabled
    }
}
