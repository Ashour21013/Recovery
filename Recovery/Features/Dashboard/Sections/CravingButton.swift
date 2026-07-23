import SwiftUI

/// Großer, auffälliger Notfall-Button für akutes Verlangen ("Cravings").
/// Reine UI-Komponente – meldet nur die Aktion nach außen.
struct CravingButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.m) {
                Image(systemName: "hand.raised.fill")
                    .font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Ich habe gerade Cravings")
                        .font(.headline)
                    Text("Hol dir jetzt Unterstützung")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.9))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .foregroundStyle(.white)
            .padding(AppSpacing.l)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.red.gradient)
            )
        }
        .buttonStyle(.plain)
        .accessibilityHint("Öffnet Sofortmaßnahmen gegen akutes Verlangen.")
    }
}

#Preview {
    CravingButton(action: {})
        .padding()
}
