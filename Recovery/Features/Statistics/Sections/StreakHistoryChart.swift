import SwiftUI
import Charts

/// Liniendiagramm des Streak-Verlaufs der letzten 30 Tage (Swift Charts).
///
/// Zeigt bei fehlenden Daten ein dezentes Platzhalter-Chart im Hintergrund
/// plus freundlichen Empty State. Reine UI-Komponente.
struct StreakHistoryChart: View {
    let points: [StreakPoint]

    private var hasData: Bool {
        points.contains { $0.streakDays > 0 }
    }

    var body: some View {
        ChartCard(
            title: "Streak-Verlauf",
            subtitle: "Letzte 30 Tage",
            systemImage: "chart.xyaxis.line"
        ) {
            if hasData {
                chart(points)
                    .frame(height: 160)
                    .accessibilityLabel("Streak-Verlauf der letzten 30 Tage")
                    .accessibilityValue("Aktuell \(points.last?.streakDays ?? 0) Tage")
            } else {
                ZStack {
                    chart(Self.placeholder)
                        .frame(height: 160)
                        .blur(radius: 4)
                        .opacity(0.25)
                        .accessibilityHidden(true)
                    StatEmptyState(
                        systemImage: "chart.line.uptrend.xyaxis",
                        message: "Dein Streak-Verlauf erscheint hier, sobald du startest."
                    )
                }
            }
        }
    }

    private func chart(_ data: [StreakPoint]) -> some View {
        Chart(data) { point in
            AreaMark(
                x: .value("Tag", point.date),
                y: .value("Tage", point.streakDays)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [AppColor.accent.opacity(0.4), AppColor.accent.opacity(0.02)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .interpolationMethod(.catmullRom)

            LineMark(
                x: .value("Tag", point.date),
                y: .value("Tage", point.streakDays)
            )
            .foregroundStyle(AppColor.accent.gradient)
            .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))
            .interpolationMethod(.catmullRom)
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 4)) {
                AxisGridLine()
                AxisValueLabel(format: .dateTime.day().month(.abbreviated))
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic(desiredCount: 4))
        }
    }

    /// Generischer Platzhalter-Verlauf für den Empty State.
    private static let placeholder: [StreakPoint] = {
        let today = Calendar.current.startOfDay(for: .now)
        return (0..<30).reversed().map { offset in
            let day = Calendar.current.date(byAdding: .day, value: -offset, to: today) ?? today
            return StreakPoint(date: day, streakDays: max(0, 30 - offset))
        }
    }()
}

#Preview {
    StreakHistoryChart(points: [])
        .padding()
        .background(Color(.systemGroupedBackground))
}
