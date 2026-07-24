import SwiftUI

/// Screen zum Melden eines Rückfalls.
///
/// Sammelt Datum/Uhrzeit, Stärke des Verlangens, Trigger (Mehrfachauswahl)
/// und Notizen. Vor dem Speichern muss der Nutzer den Rückfall in einem
/// Bestätigungsdialog bestätigen. Die View enthält keine Persistenzlogik –
/// sie bindet an das `RelapseViewModel`.
struct RelapseView: View {

    @Environment(\.dependencies) private var dependencies
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: RelapseViewModel?
    @State private var isConfirming = false

    /// Wird nach erfolgreichem Speichern aufgerufen (z. B. Dashboard neu laden).
    let onSaved: () -> Void

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    form(viewModel)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Rückfall melden")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Melden") { isConfirming = true }
                }
            }
        }
        .task {
            if viewModel == nil {
                viewModel = RelapseViewModel(repository: dependencies.makeRecoveryRepository())
            }
            await viewModel?.onAppear()
        }
        .confirmationDialog(
            "Rückfall wirklich melden?",
            isPresented: $isConfirming,
            titleVisibility: .visible
        ) {
            Button("Rückfall melden", role: .destructive) {
                Task { await confirmSave() }
            }
            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text("Deine aktuelle Streak wird zurückgesetzt. Deine längste Streak bleibt erhalten.")
        }
    }

    // MARK: - Formular

    private func form(_ viewModel: RelapseViewModel) -> some View {
        Form {
            Section("Zeitpunkt") {
                DatePicker(
                    "Datum & Uhrzeit",
                    selection: Binding(
                        get: { viewModel.date },
                        set: { viewModel.date = $0 }
                    ),
                    in: ...Date.now
                )
            }

            Section("Stärke des Verlangens") {
                VStack(alignment: .leading, spacing: AppSpacing.s) {
                    HStack {
                        Text("Intensität")
                        Spacer()
                        Text("\(viewModel.cravingIntensity)/10")
                            .font(.headline)
                            .foregroundStyle(AppColor.accent)
                    }
                    Slider(
                        value: Binding(
                            get: { Double(viewModel.cravingIntensity) },
                            set: { viewModel.cravingIntensity = Int($0.rounded()) }
                        ),
                        in: 1...10,
                        step: 1
                    )
                }
            }

            Section("Trigger") {
                if viewModel.suggestedTriggers.isEmpty {
                    Text("Füge unten deinen ersten Trigger hinzu.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    FlowLayout {
                        ForEach(viewModel.suggestedTriggers, id: \.self) { name in
                            SelectableChip(
                                title: name,
                                isSelected: viewModel.isSelected(name),
                                action: { viewModel.toggleTrigger(name) }
                            )
                        }
                    }
                    .padding(.vertical, AppSpacing.xs)
                }

                HStack {
                    TextField("Neuer Trigger", text: Binding(
                        get: { viewModel.newTriggerName },
                        set: { viewModel.newTriggerName = $0 }
                    ))
                    Button("Hinzufügen", action: viewModel.addCustomTrigger)
                        .disabled(viewModel.newTriggerName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }

            Section("Notizen") {
                AppTextEditor(
                    placeholder: "Was ist passiert? Was kannst du daraus lernen?",
                    text: Binding(
                        get: { viewModel.note },
                        set: { viewModel.note = $0 }
                    ),
                    minHeight: 120
                )
                .listRowInsets(EdgeInsets())
                .padding(.vertical, AppSpacing.xs)
            }
        }
    }

    private func confirmSave() async {
        guard let viewModel else { return }
        await viewModel.save()
        if viewModel.didSave {
            onSaved()
            dismiss()
        }
    }
}

#Preview {
    RelapseView(onSaved: {})
}
