import SwiftUI

/// Kompakte Kennzahl-Karte (Wert + Beschriftung + Icon).
/// Reine, wiederverwendbare UI-Komponente ohne Geschäftslogik.
struct StatCard: View {
    let value: String
    let label: String
    let systemImage: String
    var tint: Color = AppColor.accent

    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: AppSpacing.s) {
                Image(systemName: systemImage)
                    .font(.title3)
                    .foregroundStyle(tint)

                Text(value)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())

                Text(label)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    HStack {
        StatCard(value: "12", label: "Aktuelle Streak", systemImage: "flame.fill")
        StatCard(value: "21", label: "Längste Streak", systemImage: "trophy.fill", tint: .yellow)
    }
    .padding()
}
