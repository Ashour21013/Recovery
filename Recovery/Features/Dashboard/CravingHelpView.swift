import SwiftUI

/// Sofortmaßnahmen bei akutem Verlangen ("Cravings").
///
/// Wird als Sheet vom Dashboard präsentiert. Aktuell statische Tipps
/// (Mock); später können hier interaktive Übungen ergänzt werden.
struct CravingHelpView: View {
    let onDismiss: () -> Void

    private let tips: [(icon: String, title: String, subtitle: String)] = [
        ("wind", "Atme tief durch", "4 Sekunden ein, 4 halten, 4 aus – 5-mal wiederholen."),
        ("figure.walk", "Bewege dich", "Ein kurzer Spaziergang senkt den Drang deutlich."),
        ("drop.fill", "Trink ein Glas Wasser", "Lenkt ab und gibt deinem Körper etwas zu tun."),
        ("timer", "Warte 10 Minuten", "Verlangen kommt in Wellen – es geht vorbei.")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.m) {
                    Text("Das Verlangen ist vorübergehend. Du schaffst das.")
                        .font(.title3.weight(.semibold))
                        .padding(.bottom, AppSpacing.s)

                    ForEach(tips, id: \.title) { tip in
                        CardContainer {
                            HStack(spacing: AppSpacing.m) {
                                Image(systemName: tip.icon)
                                    .font(.title2)
                                    .foregroundStyle(AppColor.accent)
                                    .frame(width: 32)
                                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                    Text(tip.title).font(.headline)
                                    Text(tip.subtitle)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                .padding(AppSpacing.m)
            }
            .navigationTitle("Durchhalten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig", action: onDismiss)
                }
            }
        }
    }
}

#Preview {
    CravingHelpView(onDismiss: {})
}
