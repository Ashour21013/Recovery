import SwiftUI

/// Erklärt transparent, wie die App mit den Daten des Nutzers umgeht.
///
/// Recovery speichert alle Daten ausschließlich lokal auf dem Gerät.
/// Reine, statische UI-Komponente.
struct PrivacyView: View {

    private let points: [(icon: String, title: String, text: String)] = [
        ("lock.fill", "Alles bleibt bei dir",
         "Deine Einträge, Trigger und Fortschritte werden ausschließlich lokal auf deinem Gerät gespeichert."),
        ("wifi.slash", "Keine Server, kein Tracking",
         "Recovery sendet keine Daten an externe Server und nutzt keine Analyse- oder Tracking-Dienste."),
        ("square.and.arrow.up", "Du hast die Kontrolle",
         "Du kannst deine Daten jederzeit als Datei exportieren oder unwiderruflich löschen."),
        ("hand.raised.fill", "Vertraulich",
         "Niemand außer dir hat Zugriff auf deine sensiblen Informationen.")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.l) {
                HStack {
                    Spacer()
                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 56))
                        .foregroundStyle(AppColor.accent.gradient)
                        .symbolRenderingMode(.hierarchical)
                    Spacer()
                }
                .padding(.top, AppSpacing.m)

                Text("Deine Privatsphäre")
                    .font(AppFont.title)

                Text("Recovery ist ein sehr persönlicher Begleiter. Deshalb behandeln wir deine Daten mit größtem Respekt.")
                    .font(.body)
                    .foregroundStyle(.secondary)

                VStack(spacing: AppSpacing.m) {
                    ForEach(Array(points.enumerated()), id: \.offset) { _, point in
                        HStack(alignment: .top, spacing: AppSpacing.m) {
                            Image(systemName: point.icon)
                                .font(.title3)
                                .foregroundStyle(AppColor.accent)
                                .frame(width: 32)
                            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                Text(point.title)
                                    .font(.headline)
                                Text(point.text)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(AppSpacing.m)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(.secondarySystemBackground))
                        )
                    }
                }
            }
            .padding(AppSpacing.l)
        }
        .navigationTitle("Datenschutz")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        PrivacyView()
    }
}
