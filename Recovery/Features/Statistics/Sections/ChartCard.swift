import SwiftUI

/// Wiederverwendbarer Karten-Container für ein Diagramm mit Titel und
/// optionalem Untertitel. Reine UI-Komponente.
struct ChartCard<Content: View>: View {
    let title: String
    var subtitle: String?
    var systemImage: String?
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.m) {
            VStack(alignment: .leading, spacing: 2) {
                Label {
                    Text(title).font(AppFont.headline)
                } icon: {
                    if let systemImage {
                        Image(systemName: systemImage)
                            .foregroundStyle(AppColor.accent)
                    }
                }
                if let subtitle {
                    Text(subtitle)
                        .font(AppFont.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.m)
        .background(
            AppColor.cardBackground,
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
    }
}

#Preview {
    ChartCard(title: "Streak-Verlauf", subtitle: "Letzte 30 Tage", systemImage: "chart.xyaxis.line") {
        Rectangle().fill(.blue.opacity(0.2)).frame(height: 120)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
