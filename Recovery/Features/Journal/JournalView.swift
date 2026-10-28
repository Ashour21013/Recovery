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
                .navigationTitle("Tagebuch")
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
        .onReceive(NotificationCenter.default.publisher(for: .activeAddictionDidChange)) { _ in
            Task { await viewModel?.load() }
        }
        .sheet(isPresented: $isShowingEditor) {
            JournalEditorView(
                onSave: { entry in
                    isShowingEditor = false
                    Task { await viewModel?.addEntry(entry) }
                },
                onCancel: { isShowingEditor = false },
                knownTriggers: viewModel?.knownTriggers ?? []
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
            Section {
                Text("Ein sicherer Ort für deine Gedanken.")
                    .font(.subheadline)
                    .foregroundStyle(AppColor.muted)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 4, trailing: 20))
                Button { isShowingEditor = true } label: {
                    Label("Neuen Eintrag schreiben", systemImage: "plus")
                }
                .buttonStyle(TealButtonStyle())
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 4, leading: 18, bottom: 10, trailing: 18))
            }
            .listRowSeparator(.hidden)

            ForEach(entries) { entry in
                JournalEntryRow(entry: entry)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 18, bottom: 4, trailing: 18))
            }
            .onDelete { indexSet in
                let ids = indexSet.map { entries[$0].id }
                Task {
                    for id in ids { await viewModel?.deleteEntry(id: id) }
                }
            }
        }
        .listStyle(.plain)
        .figmaScreenBackground()
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Spacer()
            IconTile(systemImage: "book", size: 72)
            Text("Noch keine Einträge")
                .font(.title3.weight(.bold))
                .foregroundStyle(AppColor.ink)
            Text("Ein sicherer Ort für deine Gedanken. Halte Stimmung, Trigger und Gedanken fest.")
                .font(.subheadline)
                .foregroundStyle(AppColor.muted)
                .multilineTextAlignment(.center)
            Button { isShowingEditor = true } label: {
                Label("Ersten Eintrag schreiben", systemImage: "plus")
            }
            .buttonStyle(TealButtonStyle())
            .padding(.top, 8)
            Spacer()
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background.ignoresSafeArea())
    }
}

#Preview {
    JournalView()
}
