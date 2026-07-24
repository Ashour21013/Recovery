import SwiftUI

/// Journal-Screen: Liste der Einträge mit Möglichkeit, neue zu erfassen.
///
/// Die View bindet an das `JournalViewModel` und greift nie direkt auf
/// SwiftData zu. Neue Einträge werden über einen Editor als Sheet erfasst.
struct JournalView: View {

    @Environment(\.dependencies) private var dependencies
    @State private var viewModel: JournalViewModel?
    @State private var isShowingEditor = false

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Journal")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            isShowingEditor = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .accessibilityLabel("Neuen Eintrag hinzufügen")
                    }
                }
        }
        .task {
            if viewModel == nil {
                viewModel = JournalViewModel(repository: dependencies.makeRecoveryRepository())
            }
            await viewModel?.onAppear()
        }
        .sheet(isPresented: $isShowingEditor) {
            JournalEditorView(
                onSave: { entry in
                    isShowingEditor = false
                    Task { await viewModel?.addEntry(entry) }
                },
                onCancel: { isShowingEditor = false }
            )
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel?.state {
        case .loaded(let entries) where !entries.isEmpty:
            list(entries)

        case .loaded:
            emptyState

        case .failed:
            ContentUnavailableView(
                "Konnte nicht laden",
                systemImage: "exclamationmark.triangle",
                description: Text("Bitte versuche es erneut.")
            )

        default:
            ProgressView("Lädt…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func list(_ entries: [JournalEntry]) -> some View {
        List {
            ForEach(entries) { entry in
                JournalEntryRow(entry: entry)
            }
            .onDelete { indexSet in
                let ids = indexSet.map { entries[$0].id }
                Task {
                    for id in ids { await viewModel?.deleteEntry(id: id) }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("Noch keine Einträge", systemImage: "book.closed")
        } description: {
            Text("Halte täglich deine Stimmung, Trigger und Gedanken fest.")
        } actions: {
            Button("Ersten Eintrag erstellen") { isShowingEditor = true }
                .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    JournalView()
}
