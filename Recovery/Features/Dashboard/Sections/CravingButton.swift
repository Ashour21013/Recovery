import SwiftUI

/// Großer, auffälliger Notfall-Button für akutes Verlangen ("Cravings").
/// Reine UI-Komponente – meldet nur die Aktion nach außen.
struct CravingButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.m) {
                Image(systemName: "shield.fill")
                    .font(.title3)
                    .frame(width: 42, height: 42)
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(.white.opacity(0.14)))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Ich habe Verlangen")
                        .font(AppFont.headline)
                    Text("Wir gehen da gemeinsam durch")
                        .font(AppFont.caption)
                        .foregroundStyle(.white.opacity(0.75))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(AppFont.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 15)
            .padding(.vertical, 11)
            .frame(maxWidth: .infinity, minHeight: 68, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(LinearGradient(colors: [Color(hex: 0x1A8179), AppColor.deep],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .shadow(color: AppColor.deep.opacity(0.22), radius: 12, y: 10)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Ich habe gerade Cravings")
        .accessibilityHint("Öffnet Sofortmaßnahmen gegen akutes Verlangen.")
    }
}

#Preview {
    CravingButton(action: {})
        .padding()
}
