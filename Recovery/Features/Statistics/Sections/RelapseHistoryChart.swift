import SwiftUI
import Charts

/// Balkendiagramm der Rückfälle pro Woche (Swift Charts).
///
/// Zeigt bei fehlenden Daten ein dezentes Platzhalter-Chart plus freundlichen
/// Empty State. Reine UI-Komponente.
struct RelapseHistoryChart: View {
    let buckets: [RelapseBucket]

    private var hasData: Bool {
        buckets.contains { $0.count > 0 }
    }

    var body: some View {
        ChartCard(
            title: "Rückfälle über Zeit",
            subtitle: "Pro Woche",
            systemImage: "chart.bar.fill"
        ) {
            if hasData {
                chart(buckets)
                    .frame(height: 160)
                    .accessibilityLabel("Rückfälle pro Woche")
                    .accessibilityValue("Insgesamt \(buckets.reduce(0) { $0 + $1.count }) Rückfälle")
            } else {
                ZStack {
                    chart(Self.placeholder)
                        .frame(height: 160)
                        .blur(radius: 4)
                        .opacity(0.25)
                        .accessibilityHidden(true)
                    StatEmptyState(
                        systemImage: "checkmark.seal.fill",
                        message: "Noch keine Rückfälle erfasst – bleib dran!"
                    )
                }
            }
        }
    }

    private func chart(_ data: [RelapseBucket]) -> some View {
        Chart(data) { bucket in
            BarMark(
                x: .value("Woche", bucket.periodStart, unit: .weekOfYear),
                y: .value("Rückfälle", bucket.count),
                width: .ratio(0.6)
            )
            .foregroundStyle(Color.red.gradient)
            .cornerRadius(6)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .weekOfYear, count: 2)) {
                AxisGridLine()
                AxisValueLabel(format: .dateTime.day().month(.abbreviated))
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic(desiredCount: 3))
        }
    }

    /// Generische Platzhalter-Balken für den Empty State.
    private static let placeholder: [RelapseBucket] = {
        let calendar = Calendar.current
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: .now)?.start ?? .now
        let values = [1, 0, 2, 1, 0, 1, 0, 1]
        return values.enumerated().reversed().compactMap { index, value in
            guard let start = calendar.date(byAdding: .weekOfYear, value: -index, to: weekStart) else {
                return nil
            }
            return RelapseBucket(periodStart: start, count: value)
        }
    }()
}

#Preview {
    RelapseHistoryChart(buckets: [])
        .padding()
        .background(Color(.systemGroupedBackground))
}
