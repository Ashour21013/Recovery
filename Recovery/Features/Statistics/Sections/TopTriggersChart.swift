import SwiftUI

/// Verständliche Rangliste der häufigsten Trigger.
///
/// Statt eines abstrakten Balkendiagramms mit Achsen zeigt jede Zeile:
/// Rang, Name, „x× notiert“, Anteil in % und einen Fortschrittsbalken.
/// Darunter ein konkreter Hinweis zum stärksten Auslöser.
/// Reine UI-Komponente – erhält bereits aufbereitete Daten.
struct TopTriggersChart: View {
    let triggers: [TriggerFrequency]

    @State private var appeared = false

    private var total: Int { triggers.reduce(0) { $0 + $1.count } }
    private var maxCount: Int { triggers.map(\.count).max() ?? 1 }

    var body: some View {
        ChartCard(
            title: String(localized: "Häufigste Trigger"),
            subtitle: triggers.isEmpty ? nil : String(localized: "Top \(triggers.count) · \(total)× notiert"),
            systemImage: "bolt.fill"
        ) {
            if triggers.isEmpty {
                StatEmptyState(
                    systemImage: "bolt.slash.fill",
                    message: String(localized: "Notiere im Tagebuch, was dich herausgefordert hat. Hier siehst du dann, welche Auslöser am häufigsten vorkommen.")
                )
            } else {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Situationen, die du am öftesten als Auslöser notiert hast. Der Prozentwert zeigt, wie groß ihr Anteil ist.")
                        .font(.footnote)
                        .foregroundStyle(AppColor.muted)

                    VStack(spacing: 10) {
                        ForEach(Array(triggers.enumerated()), id: \.element.id) { index, trigger in
                            row(rank: index + 1, trigger: trigger)
                        }
                    }

                    if let top = triggers.first {
                        insight(for: top)
                    }
                }
                .onAppear {
                    withAnimation(.smooth(duration: 0.8).delay(0.1)) { appeared = true }
                }
            }
        }
    }

    // MARK: - Zeile

    private func row(rank: Int, trigger: TriggerFrequency) -> some View {
        let share = total > 0 ? Double(trigger.count) / Double(total) : 0
        let relative = Double(trigger.count) / Double(max(maxCount, 1))
        let isTop = rank == 1
        let tint = isTop ? AppColor.coral : AppColor.teal

        return HStack(spacing: 12) {
            Text("\(rank)")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(isTop ? .white : tint)
                .frame(width: 30, height: 30)
                .background(Circle().fill(isTop ? tint : tint.opacity(0.12)))

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(trigger.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColor.ink)
                        .lineLimit(1)
                    Spacer(minLength: 8)
                    Text(share, format: .percent.precision(.fractionLength(0)))
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(tint)
                        .monospacedDigit()
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(AppColor.line.opacity(0.6))
                        Capsule()
                            .fill(tint.gradient)
                            .frame(width: appeared ? max(8, geo.size.width * relative) : 0)
                    }
                }
                .frame(height: 6)

                Text(trigger.count == 1 ? "1× notiert" : "\(trigger.count)× notiert")
                    .font(.caption)
                    .foregroundStyle(AppColor.muted)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous)
                .fill(isTop ? AppColor.coralSoft.opacity(0.5) : AppColor.background)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Platz \(rank): \(trigger.name), \(trigger.count) mal notiert, \(Int((share * 100).rounded())) Prozent")
    }

    // MARK: - Hinweis

    private func insight(for top: TriggerFrequency) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "lightbulb")
                .foregroundStyle(AppColor.gold)
            Text("**\(top.name)** ist dein stärkster Auslöser. Überlege dir einen Plan, was du stattdessen tust, wenn diese Situation auftritt.")
                .font(.footnote)
                .foregroundStyle(AppColor.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous).fill(AppColor.goldSoft.opacity(0.6)))
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
