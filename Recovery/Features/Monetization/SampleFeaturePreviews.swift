import SwiftUI

/// Generisches, dezentes Beispiel-Balkendiagramm für gesperrte Statistik-
/// Teaser. Zeigt **keine** echten Nutzerdaten – rein illustrativ.
struct SampleChartPreview: View {
    private let bars: [Double] = [0.4, 0.7, 0.5, 0.9, 0.6, 0.8]

    var body: some View {
        HStack(alignment: .bottom, spacing: AppSpacing.s) {
            ForEach(Array(bars.enumerated()), id: \.offset) { _, value in
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(AppColor.accent.opacity(0.5))
                    .frame(height: CGFloat(value) * 120)
            }
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.l)
    }
}

/// Generische, dezente Beispiel-Kennzahlen für gesperrte Gain-Teaser.
/// Zeigt **keine** echten Nutzerdaten – rein illustrativ.
struct SampleMetricsPreview: View {
    var body: some View {
        HStack(spacing: AppSpacing.l) {
            sample(value: "128 €", label: "Gespart")
            sample(value: "36 Std.", label: "Zurückgewonnen")
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.l)
    }

    private func sample(value: String, label: String) -> some View {
        VStack(spacing: AppSpacing.xs) {
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(.primary)
            Text(label)
                .font(AppFont.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    VStack {
        SampleChartPreview()
        SampleMetricsPreview()
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
