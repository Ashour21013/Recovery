import SwiftUI
import Charts

/// Balkendiagramm der häufigsten Trigger (Swift Charts).
/// Reine UI-Komponente – erhält bereits aufbereitete Daten.
struct TopTriggersChart: View {
    let triggers: [TriggerFrequency]

    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: AppSpacing.m) {
                Text("Häufigste Trigger")
                    .font(AppFont.headline)

                if triggers.isEmpty {
                    Text("Noch keine Trigger erfasst.")
                        .font(AppFont.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, AppSpacing.m)
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
}
