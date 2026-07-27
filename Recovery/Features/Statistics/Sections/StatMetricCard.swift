import SwiftUI

/// Hochwertige Kennzahl-Karte im Stil einer erstklassigen Apple-App.
///
/// Zeigt Icon, große animierte Zahl (`contentTransition(.numericText())`),
/// optionale Einheit und Titel auf einem dezenten Akzent-Farbverlauf.
/// Reine, wiederverwendbare UI-Komponente ohne Geschäftslogik.
struct StatMetricCard: View {
    let metric: StatMetric

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.s) {
            Image(systemName: metric.systemImage)
                .font(.title2)
                .foregroundStyle(metric.tint)
                .symbolEffect(.bounce, value: metric.value)
                .accessibilityHidden(true)

            Spacer(minLength: AppSpacing.s)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(metric.value)")
                    .font(AppFont.roundedNumber(relativeTo: .largeTitle))
                    .contentTransition(.numericText())
                    .animation(.smooth, value: metric.value)
                if let unit = metric.unit {
                    Text(unit)
                        .font(AppFont.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }

            Text(metric.label)
                .font(AppFont.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 128, alignment: .leading)
        .padding(AppSpacing.m)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AppColor.cardBackground)
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [metric.tint.opacity(0.18), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
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
