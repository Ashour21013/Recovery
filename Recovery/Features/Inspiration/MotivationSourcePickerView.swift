import SwiftUI

/// Sheet zur Auswahl der täglichen Motivationsquelle.
/// Reine UI – meldet die Auswahl nach außen.
struct MotivationSourcePickerView: View {
    let current: MotivationSource
    let onSelect: (MotivationSource) -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(MotivationSource.allCases) { source in
                        Button {
                            onSelect(source)
                        } label: {
                            HStack(spacing: AppSpacing.m) {
                                Image(systemName: source.systemImage)
                                    .foregroundStyle(AppColor.accent)
                                    .frame(width: 30)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(source.title)
                                        .foregroundStyle(.primary)
                                    Text(source.subtitle)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if source == current {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(AppColor.accent)
                                        .fontWeight(.semibold)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                } footer: {
                    Text("Bibelverse werden passend zu deiner Situation gewählt – z. B. Vergebung nach einem Rückfall oder Stärke bei Verlangen.")
                }
            }
            .navigationTitle("Tägliche Motivation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen", action: onCancel)
                }
            }
        }
    }
}

#Preview {
    MotivationSourcePickerView(current: .bible, onSelect: { _ in }, onCancel: {})
}
