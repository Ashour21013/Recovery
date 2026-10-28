import SwiftUI

/// Zeigt die aktuelle Streak (cleane Tage) prominent an.
/// Reine UI-Komponente – erhält bereits aufbereitete Daten.
struct StreakCardView: View {
    let streak: Streak

    private func elapsed(at now: Date) -> (days: Int, hours: Int, minutes: Int) {
        let total = max(0, Int(now.timeIntervalSince(streak.startedAt)) / 60)
        return (total / 1440, (total % 1440) / 60, total % 60)
    }

    private func counterPart(_ value: Int, _ unit: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(unit == String(localized: "Tage") ? "\(value)" : String(format: "%02d", value))
                .font(.system(.headline, design: .rounded).weight(.bold))
                .contentTransition(.numericText())
            Text(unit)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.72))
        }
    }

    private var dot: some View {
        Circle().fill(.white.opacity(0.4)).frame(width: 3, height: 3)
    }

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            HStack {
                Label("DEIN STREAK", systemImage: "flame.fill")
                    .font(.caption2.weight(.heavy))
                    .tracking(1)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(.white.opacity(0.13)))
                Spacer()
            }

            Text("\(streak.currentDays)")
                .font(.system(size: 104, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .contentTransition(.numericText(value: Double(streak.currentDays)))
                .animation(.smooth, value: streak.currentDays)
                .padding(.top, AppSpacing.s)

            Text(streak.currentDays == 1 ? String(localized: "Tag frei") : String(localized: "Tage frei"))
                .font(.title2.weight(.semibold))

            TimelineView(.periodic(from: .now, by: 30)) { context in
                let parts = elapsed(at: context.date)
                HStack(spacing: 12) {
                    counterPart(parts.days, String(localized: "Tage"))
                    dot
                    counterPart(parts.hours, String(localized: "Std"))
                    dot
                    counterPart(parts.minutes, String(localized: "Min"))
                }
            }
            .padding(.top, 12)

            Rectangle().fill(.white.opacity(0.16)).frame(height: 1)
                .padding(.top, 10)

            HStack(spacing: 7) {
                Image(systemName: streak.isNewRecord ? "trophy.fill" : "medal")
                    .symbolEffect(.bounce, value: streak.isNewRecord)
                    .accessibilityHidden(true)
                if streak.isNewRecord {
                    Text("Neuer Rekord!")
                } else {
                    Text("Dein Rekord: **\(streak.bestDays) Tage**")
                }
                Spacer()
                Text("Seit \(streak.startedAt.formatted(date: .abbreviated, time: .omitted))")
            }
            .font(.caption)
            .foregroundStyle(.white.opacity(0.8))
            .padding(.top, 6)
        }
        .foregroundStyle(.white)
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                AppColor.heroGradient
                RadialGradient(colors: [Color(hex: 0xB1EEDE, opacity: 0.3), .clear],
                               center: UnitPoint(x: 0.8, y: 0.1), startRadius: 0, endRadius: 160)
                Circle()
                    .stroke(.white.opacity(0.09), lineWidth: 1)
                    .frame(width: 190, height: 190)
                    .offset(x: 130, y: 10)
            }
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.hero, style: .continuous))
            .shadow(color: AppColor.deep.opacity(0.25), radius: 18, y: 14)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityDescription)
    }

    /// Zusammenhängende, natürlich vorgelesene Beschreibung für VoiceOver,
    /// statt einzelner Fragmente.
    private var accessibilityDescription: String {
        if streak.currentDays == 1 {
            let base = String(localized: "Aktuelle Streak: 1 Tag.")
            return base + (streak.isNewRecord
                ? String(localized: " Neuer Rekord!")
                : String(localized: " Bestwert: \(streak.bestDays) Tage."))
        }
        let base = String(localized: "Aktuelle Streak: \(streak.currentDays) Tage.")
        let record = streak.isNewRecord
            ? String(localized: " Neuer Rekord!")
            : String(localized: " Bestwert: \(streak.bestDays) Tage.")
        return base + record
    }
}

#Preview {
    StreakCardView(
        streak: Streak(currentDays: 12, bestDays: 21, startedAt: .now)
    )
    .padding()
}
