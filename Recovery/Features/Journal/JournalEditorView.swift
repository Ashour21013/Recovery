import SwiftUI

/// Editor zum Erfassen eines neuen Journal-Eintrags.
///
/// Reine UI: sammelt Stimmung, Trigger und Notizen und meldet den fertigen
/// `JournalEntry` über `onSave` nach außen. Enthält keine Persistenzlogik.
struct JournalEditorView: View {

    let onSave: (JournalEntry) -> Void
    let onCancel: () -> Void
    /// Bereits genutzte Trigger für die Schnellauswahl.
    var knownTriggers: [String] = []

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
                    section(title: String(localized: "Wie fühlst du dich heute?")) {
                        MoodPicker(selection: $mood)
                    }

                    section(title: String(localized: "Gab es einen Trigger?")) {
                        VStack(alignment: .leading, spacing: AppSpacing.s) {
                            if !knownTriggers.isEmpty {
                                FlowLayout {
                                    ForEach(knownTriggers, id: \.self) { name in
                                        SelectableChip(
                                            title: name,
                                            isSelected: triggerName.trimmed.caseInsensitiveEquals(name),
                                            action: { selectTrigger(name) }
                                        )
                                    }
                                }
                            }

                            TextField("z. B. Stress, Langeweile, Feier…", text: $triggerName)
                                .textFieldStyle(.roundedBorder)
                        }
                    }

                    section(title: String(localized: "Notizen")) {
                        AppTextEditor(
                            placeholder: String(localized: "Was möchtest du festhalten?"),
                            text: $notes,
                            minHeight: 160
                        )
                    }
                }
                .padding(AppSpacing.l)
            }
            .navigationTitle("Neuer Eintrag")
            .tint(AppColor.teal)
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

    /// Wählt einen Trigger-Chip aus bzw. hebt die Auswahl wieder auf.
    private func selectTrigger(_ name: String) {
        if triggerName.trimmed.caseInsensitiveEquals(name) {
            triggerName = ""
        } else {
            triggerName = name
        }
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

    func caseInsensitiveEquals(_ other: String) -> Bool {
        compare(other, options: .caseInsensitive) == .orderedSame
    }
}

#Preview {
    JournalEditorView(onSave: { _ in }, onCancel: {})
}
