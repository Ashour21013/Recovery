import SwiftUI

/// Wiederverwendbare, horizontale Stimmungsauswahl (1–5) mit Emojis.
/// Reine UI-Komponente ohne Geschäftslogik.
struct MoodPicker: View {
    @Binding var selection: Mood?

    var body: some View {
        HStack(spacing: AppSpacing.s) {
            ForEach(Mood.allCases) { mood in
                Button {
                    selection = (selection == mood) ? nil : mood
                } label: {
                    Text(mood.emoji)
                        .font(.system(size: 30))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.s)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selection == mood
                                      ? AppColor.accent.opacity(0.18)
                                      : Color(.secondarySystemBackground))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selection == mood ? AppColor.accent : .clear, lineWidth: 1.5)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(mood.title)
                .accessibilityAddTraits(selection == mood ? [.isSelected] : [])
            }
        }
    }
}

#Preview {
    MoodPicker(selection: .constant(.good))
        .padding()
}
