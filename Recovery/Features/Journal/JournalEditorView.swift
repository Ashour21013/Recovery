import SwiftUI

/// Editor zum Erfassen eines neuen Journal-Eintrags.
///
/// Reine UI: sammelt Stimmung, Trigger und Notizen und meldet den fertigen
/// `JournalEntry` über `onSave` nach außen. Enthält keine Persistenzlogik.
struct JournalEditorView: View {

    let onSave: (JournalEntry) -> Void
    let onCancel: () -> Void

    @State private var mood: Mood?
    @State private var triggerName: String = ""
    @State private var notes: String = ""

    private var canSave: Bool {
        mood != nil || !triggerName.trimmed.isEmpty || !notes.trimmed.isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.l) {
                    section(title: "Wie fühlst du dich heute?") {
                        MoodPicker(selection: $mood)
                    }

                    section(title: "Gab es einen Trigger?") {
                        TextField("z. B. Stress, Langeweile, Feier…", text: $triggerName)
                            .textFieldStyle(.roundedBorder)
                    }

                    section(title: "Notizen") {
                        AppTextEditor(
                            placeholder: "Was möchtest du festhalten?",
                            text: $notes,
                            minHeight: 160
                        )
                    }
                }
                .padding(AppSpacing.l)
            }
            .navigationTitle("Neuer Eintrag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern", action: save)
                        .disabled(!canSave)
                }
            }
        }
    }

    private func save() {
        let entry = JournalEntry(
            text: notes.trimmed,
            mood: mood?.rawValue,
            triggerName: triggerName.trimmed.isEmpty ? nil : triggerName.trimmed
        )
        onSave(entry)
    }

    private func section<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.s) {
            Text(title)
                .font(.headline)
            content()
        }
    }
}

private extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}

#Preview {
    JournalEditorView(onSave: { _ in }, onCancel: {})
}
