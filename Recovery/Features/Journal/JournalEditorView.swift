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
    @State private var title: String = ""
    @State private var notes: String = ""
    @FocusState private var notesFocused: Bool

    private let maxLength = 2000
    private let now = Date.now

    private let prompts = [
        String(localized: "Was war heute schwierig?"),
        String(localized: "Worauf bist du stolz?"),
        String(localized: "Was hat dir geholfen?"),
        String(localized: "Wofür bist du dankbar?")
    ]

    private var canSave: Bool {
        mood != nil || !triggerName.trimmed.isEmpty || !notes.trimmed.isEmpty || !title.trimmed.isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    dateHeader
                    moodCard
                    thoughtsCard
                    triggerCard
                    gentleHint
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(AppColor.background.ignoresSafeArea())
            .safeAreaInset(edge: .bottom) { saveButton }
            .navigationTitle("Neuer Eintrag")
            .tint(AppColor.teal)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen", action: onCancel)
                        .foregroundStyle(AppColor.muted)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern", action: save)
                        .fontWeight(.semibold)
                        .disabled(!canSave)
                }
            }
        }
    }

    // MARK: - Sections

    private var dateHeader: some View {
        HStack(spacing: 14) {
            IconTile(systemImage: "flag", size: 44)
            VStack(alignment: .leading, spacing: 2) {
                Eyebrow("Heute")
                Text(now.formatted(.dateTime.weekday(.wide).day().month(.wide)) + " · " +
                     now.formatted(date: .omitted, time: .shortened))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColor.ink)
            }
        }
    }

    private var moodCard: some View {
        card {
            VStack(spacing: 14) {
                Eyebrow("Wie fühlst du dich?")
                HStack(alignment: .top, spacing: 0) {
                    ForEach(Mood.allCases) { item in
                        moodButton(item).frame(maxWidth: .infinity)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func moodButton(_ item: Mood) -> some View {
        let isSelected = mood == item
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                mood = isSelected ? nil : item
            }
        } label: {
            VStack(spacing: 6) {
                Image(systemName: item.symbol)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(isSelected ? .white : AppColor.muted)
                    .frame(width: 54, height: 54)
                    .background(Circle().fill(isSelected ? AppColor.teal : AppColor.background))
                    .overlay(Circle().stroke(isSelected ? .clear : AppColor.line, lineWidth: 1.5))
                    .shadow(color: isSelected ? AppColor.teal.opacity(0.3) : .clear, radius: 8, y: 4)
                    .scaleEffect(isSelected ? 1.08 : 1)
                Text(item.title)
                    .font(.caption2.weight(isSelected ? .bold : .regular))
                    .foregroundStyle(isSelected ? AppColor.teal : AppColor.muted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.title)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    private var thoughtsCard: some View {
        card {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Eyebrow("Deine Gedanken")
                        Text("Was bewegt dich gerade?")
                            .font(.title3.weight(.medium))
                            .foregroundStyle(AppColor.ink)
                    }
                    Spacer()
                    Image(systemName: "leaf")
                        .font(.title3)
                        .foregroundStyle(AppColor.teal)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(prompts, id: \.self) { prompt in
                            Button { applyPrompt(prompt) } label: {
                                Text(prompt)
                                    .font(.footnote)
                                    .foregroundStyle(AppColor.muted)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(Capsule().fill(AppColor.background))
                                    .overlay(Capsule().stroke(AppColor.line))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, -18)
                .contentMargins(.horizontal, 18, for: .scrollContent)

                TextField("Titel hinzufügen (optional)", text: $title)
                    .font(.headline)
                    .foregroundStyle(AppColor.ink)
                    .padding(.vertical, 8)
                Divider().overlay(AppColor.line)

                ZStack(alignment: .topLeading) {
                    if notes.isEmpty {
                        Text("Schreib einfach los. Hier gibt es kein Richtig oder Falsch …")
                            .foregroundStyle(AppColor.muted.opacity(0.7))
                            .padding(.top, 8)
                            .padding(.leading, 5)
                            .allowsHitTesting(false)
                    }
                    TextEditor(text: $notes)
                        .focused($notesFocused)
                        .scrollContentBackground(.hidden)
                        .foregroundStyle(AppColor.ink)
                        .frame(minHeight: 180)
                        .onChange(of: notes) { _, newValue in
                            if newValue.count > maxLength { notes = String(newValue.prefix(maxLength)) }
                        }
                }

                Divider().overlay(AppColor.line)
                HStack {
                    Label("Nur für dich", systemImage: "shield")
                        .foregroundStyle(AppColor.teal)
                    Spacer()
                    Text("\(notes.count)/\(maxLength)")
                        .foregroundStyle(AppColor.muted)
                        .monospacedDigit()
                }
                .font(.caption)
            }
        }
    }

    /// App-spezifische Ergänzung: Trigger erfassen (fließt in die Statistik ein).
    private var triggerCard: some View {
        card {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    IconTile(systemImage: "bolt.heart", foreground: AppColor.coral, background: AppColor.coralSoft, size: 32)
                    VStack(alignment: .leading, spacing: 2) {
                        Eyebrow("Trigger (optional)")
                        Text("Gab es einen Auslöser?")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppColor.ink)
                    }
                }

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

                TextField("z. B. Stress, Langeweile, Feier …", text: $triggerName)
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous).fill(AppColor.background))
                    .overlay(RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous).stroke(AppColor.line))
            }
        }
    }

    private var gentleHint: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "heart")
                .font(.title3)
                .foregroundStyle(AppColor.teal)
            VStack(alignment: .leading, spacing: 2) {
                Text("Ein kleiner Gedanke")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColor.ink)
                Text(hintText)
                    .font(.footnote)
                    .foregroundStyle(AppColor.muted)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous).fill(AppColor.mint.opacity(0.35)))
    }

    private var hintText: String {
        switch mood {
        case .veryBad, .bad: "Schwere Tage gehören dazu. Dass du hier bist, ist schon ein Schritt."
        case .good, .veryGood: "Halte fest, was dir heute gutgetan hat – es hilft dir an schweren Tagen."
        default: "Du musst heute keine Lösung finden. Wahrnehmen reicht."
        }
    }

    private var saveButton: some View {
        Button(action: save) {
            Label("Eintrag speichern", systemImage: "checkmark")
        }
        .buttonStyle(TealButtonStyle(fill: canSave ? AppColor.teal : AppColor.teal.opacity(0.4)))
        .disabled(!canSave)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(AppColor.background.opacity(0.95).ignoresSafeArea())
    }

    private func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous).fill(AppColor.surface))
            .overlay(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous).stroke(AppColor.line))
    }

    // MARK: - Actions

    private func applyPrompt(_ prompt: String) {
        if title.trimmed.isEmpty { title = prompt }
        notesFocused = true
    }

    private func save() {
        let body = notes.trimmed
        let heading = title.trimmed
        let text = heading.isEmpty ? body : (body.isEmpty ? heading : "\(heading)\n\n\(body)")
        let entry = JournalEntry(
            text: text,
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

}

private extension Mood {
    /// Ruhige Linien-Symbole statt Emojis (passend zum Figma-Look).
    var symbol: String {
        switch self {
        case .veryBad: "cloud.rain"
        case .bad: "cloud"
        case .neutral: "minus"
        case .good: "sun.min"
        case .veryGood: "sun.max"
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
