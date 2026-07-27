import SwiftUI

/// Freundlicher Empty State für Chart-Bereiche ohne Daten.
///
/// Zeigt ein dezentes Icon und einen ermutigenden Text – niemals nur eine
/// nackte „0". Wird über einem optionalen Platzhalter-Chart eingesetzt.
struct StatEmptyState: View {
    let systemImage: String
    let message: String

    var body: some View {
        VStack(spacing: AppSpacing.s) {
            Image(systemName: systemImage)
                .font(.title)
                .foregroundStyle(.secondary)
            Text(message)
                .font(AppFont.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.l)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    StatEmptyState(
        systemImage: "chart.line.uptrend.xyaxis",
        message: "Deine Statistiken erscheinen hier, sobald du startest."
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
