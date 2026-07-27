import SwiftUI
import Charts

/// Horizontales Balkendiagramm der häufigsten Trigger (Swift Charts).
/// Reine UI-Komponente – erhält bereits aufbereitete Daten.
struct TopTriggersChart: View {
    let triggers: [TriggerFrequency]

    var body: some View {
        ChartCard(
            title: "Häufigste Trigger",
            subtitle: triggers.isEmpty ? nil : "Top \(triggers.count)",
            systemImage: "bolt.fill"
        ) {
            if triggers.isEmpty {
                StatEmptyState(
                    systemImage: "bolt.slash.fill",
                    message: "Sobald du Trigger erfasst, erscheinen sie hier als Diagramm."
                )
            } else {
                Chart(triggers) { trigger in
                    BarMark(
                        x: .value("Anzahl", trigger.count),
                        y: .value("Trigger", trigger.name)
                    )
                    .foregroundStyle(AppColor.accent.gradient)
                    .cornerRadius(6)
                    .annotation(position: .trailing) {
                        Text("\(trigger.count)")
                            .font(AppFont.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 4))
                }
                .frame(height: chartHeight)
                .accessibilityLabel("Häufigste Trigger")
            }
        }
    }

    /// Dynamische Höhe: pro Trigger eine feste Zeilenhöhe.
    private var chartHeight: CGFloat {
        CGFloat(max(1, triggers.count)) * 44
    }
}

#Preview {
    TopTriggersChart(triggers: [
        TriggerFrequency(name: "Stress", count: 8),
        TriggerFrequency(name: "Langeweile", count: 5),
        TriggerFrequency(name: "Feier", count: 3)
    ])
    .padding()
    .background(Color(.systemGroupedBackground))
}
