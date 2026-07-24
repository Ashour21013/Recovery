import SwiftUI

/// Editor zum Anpassen des Recovery-Plans.
///
/// Der Nutzer kann Aufgaben entfernen, Standard-Vorschläge übernehmen und
/// eigene Übungen vorschlagen. Bindet an das `PlanEditorViewModel` (MVVM).
struct PlanEditorView: View {

    @Environment(\.dependencies) private var dependencies
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: PlanEditorViewModel?

    /// Wird nach jeder Änderung aufgerufen, damit das Dashboard neu lädt.
    var onChange: () -> Void = {}

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    form(viewModel)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Plan anpassen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") { dismiss() }
                }
            }
        }
        .task {
            if viewModel == nil {
                viewModel = PlanEditorViewModel(repository: dependencies.makeRecoveryRepository())
            }
            await viewModel?.onAppear()
        }
    }

    private func form(_ viewModel: PlanEditorViewModel) -> some View {
        Form {
            currentTasksSection(viewModel)
            customSection(viewModel)
            suggestionsSection(viewModel)
        }
        .alert(
            "Fehler",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    // MARK: - Aktuelle Aufgaben

    private func currentTasksSection(_ viewModel: PlanEditorViewModel) -> some View {
        Section {
            ForEach(viewModel.tasks) { task in
                HStack(spacing: AppSpacing.m) {
                    Image(systemName: task.systemImage)
                        .foregroundStyle(AppColor.accent)
                        .frame(width: 28)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(task.title)
                            .font(.body)
                        Text(task.subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onDelete { offsets in
                Task { await viewModel.remove(at: offsets); onChange() }
            }
        } header: {
            Text("Deine Aufgaben")
        } footer: {
            Text("Streiche eine Aufgabe nach links, um sie zu entfernen.")
        }
    }

    // MARK: - Eigene Übung

    private func customSection(_ viewModel: PlanEditorViewModel) -> some View {
        Section("Eigene Übung vorschlagen") {
            TextField("Titel (z. B. Kalt duschen)", text: Binding(
                get: { viewModel.newTitle },
                set: { viewModel.newTitle = $0 }
            ))
            TextField("Kurzbeschreibung (optional)", text: Binding(
                get: { viewModel.newSubtitle },
                set: { viewModel.newSubtitle = $0 }
            ))
            Button {
                Task { await viewModel.addCustom(); onChange() }
            } label: {
                Label("Zur Liste hinzufügen", systemImage: "plus.circle.fill")
            }
            .disabled(!viewModel.canAddCustom)
        }
    }

    // MARK: - Vorschläge

    @ViewBuilder
    private func suggestionsSection(_ viewModel: PlanEditorViewModel) -> some View {
        if !viewModel.availableSuggestions.isEmpty {
            Section("Vorschläge") {
                ForEach(viewModel.availableSuggestions) { suggestion in
                    Button {
                        Task { await viewModel.addSuggestion(suggestion); onChange() }
                    } label: {
                        HStack(spacing: AppSpacing.m) {
                            Image(systemName: suggestion.systemImage)
                                .foregroundStyle(AppColor.accent)
                                .frame(width: 28)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(suggestion.title)
                                    .foregroundStyle(.primary)
                                Text(suggestion.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "plus.circle")
                                .foregroundStyle(AppColor.accent)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    PlanEditorView()
}
