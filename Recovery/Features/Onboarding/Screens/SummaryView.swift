import SwiftUI

/// Screen 5 – Zusammenfassung der erfassten Eingaben.
struct SummaryView: View {
    let draft: OnboardingDraft
    let onFinish: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.l) {
            Text("Zusammenfassung")
                .font(AppFont.title)

            VStack(spacing: AppSpacing.s) {
                summaryRow(label: "Gewohnheit", value: draft.habitType?.title ?? "–")
                summaryRow(label: "Häufigkeit", value: draft.frequency?.title ?? "–")
                reasonRow
            }

            Spacer()

            PrimaryButton(title: "Fertig", action: onFinish)
        }
        .padding(AppSpacing.l)
        .navigationTitle("Übersicht")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func summaryRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .padding(AppSpacing.m)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var reasonRow: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Motivation")
                .foregroundStyle(.secondary)
            Text(draft.reason.isEmpty ? "–" : draft.reason)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(AppSpacing.m)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    NavigationStack {
        SummaryView(
            draft: OnboardingDraft(habitType: .smoking, reason: "Für meine Gesundheit.", frequency: .daily),
            onFinish: {}
        )
    }
}
