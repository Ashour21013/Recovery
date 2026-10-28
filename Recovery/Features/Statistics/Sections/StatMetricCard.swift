import SwiftUI

/// Hochwertige Kennzahl-Karte im Stil einer erstklassigen Apple-App.
///
/// Zeigt Icon, große animierte Zahl (`contentTransition(.numericText())`),
/// optionale Einheit und Titel auf einem dezenten Akzent-Farbverlauf.
/// Reine, wiederverwendbare UI-Komponente ohne Geschäftslogik.
struct StatMetricCard: View {
    let metric: StatMetric

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: metric.systemImage)
                .font(.headline)
                .foregroundStyle(AppColor.teal)
                .frame(width: 34, height: 34)
                .background(RoundedRectangle(cornerRadius: 11, style: .continuous).fill(AppColor.mint))
                .symbolEffect(.bounce, value: metric.value)
                .accessibilityHidden(true)

            Spacer(minLength: AppSpacing.s)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(metric.value)")
                    .font(.system(size: 29, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColor.teal)
                    .contentTransition(.numericText())
                    .animation(.smooth, value: metric.value)
                if let unit = metric.unit {
                    Text(unit)
                        .font(AppFont.footnote.weight(.semibold))
                        .foregroundStyle(AppColor.muted)
                }
            }

            Text(metric.label)
                .font(AppFont.caption)
                .foregroundStyle(AppColor.muted)
        }
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppColor.surface)
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(AppColor.line, lineWidth: 1)
                }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(metric.label): \(metric.value) \(metric.unit ?? "")")
    }
}

#Preview {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
        StatMetricCard(metric: StatMetric(id: "1", value: 12, unit: "Tage", label: "Aktuelle Streak", systemImage: "flame.fill", tint: .orange))
        StatMetricCard(metric: StatMetric(id: "2", value: 21, unit: "Tage", label: "Längste Streak", systemImage: "trophy.fill", tint: .yellow))
        StatMetricCard(metric: StatMetric(id: "3", value: 2, unit: nil, label: "Rückfälle", systemImage: "arrow.uturn.backward", tint: .red))
        StatMetricCard(metric: StatMetric(id: "4", value: 5, unit: nil, label: "Trigger", systemImage: "bolt.fill", tint: .blue))
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
