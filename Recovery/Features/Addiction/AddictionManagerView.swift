import SwiftUI

/// Verwaltung aller getrackten Süchte.
///
/// Zeigt die Liste, erlaubt Wechseln (Tippen), Löschen (Swipe) und das
/// Hinzufügen weiterer Süchte. Bindet an das `AddictionManagerViewModel`.
struct AddictionManagerView: View {

    @Environment(\.dependencies) private var dependencies
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AddictionManagerViewModel?

    /// Wird nach Änderungen aufgerufen, damit das Dashboard neu lädt.
    var onChange: () -> Void = {}

    /// Bestätigungsdialog vor dem Löschen.
    @State private var pendingDeletion: AddictionSummary?

    /// Steuert die Paywall (Free-Nutzer versucht 2. Sucht anzulegen).
    @State private var isShowingPaywall = false

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    content(viewModel)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Meine Süchte")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fertig") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        addTapped()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Sucht hinzufügen")
                }
            }
            .sheet(isPresented: $isShowingPaywall) {
                PaywallView()
            }
        }
        .task {
            if viewModel == nil {
                viewModel = AddictionManagerViewModel(repository: dependencies.makeRecoveryRepository())
            }
            await viewModel?.onAppear()
        }
    }

    /// Entscheidet beim Tippen auf "+", ob der Add-Flow oder die Paywall
    /// erscheint: Free-Nutzer dürfen genau eine Sucht anlegen.
    private func addTapped() {
        guard let viewModel else { return }
        let hasAtLeastOne = !viewModel.addictions.isEmpty
        let mayAddMore = dependencies.featureAccess.isUnlocked(.multipleSuchte)
        if hasAtLeastOne && !mayAddMore {
            isShowingPaywall = true
        } else {
            viewModel.isShowingAddFlow = true
        }
    }

    @ViewBuilder
    private func content(_ viewModel: AddictionManagerViewModel) -> some View {
        List {
            Section {
                ForEach(viewModel.addictions) { addiction in
                    row(addiction, viewModel: viewModel)
                }
            } footer: {
                Text("Tippe eine Sucht an, um sie im Dashboard anzuzeigen. Wische zum Löschen.")
            }
        }
        .sheet(isPresented: Binding(
            get: { viewModel.isShowingAddFlow },
            set: { viewModel.isShowingAddFlow = $0 }
        )) {
            AddAddictionView(
                availableTypes: viewModel.availableTypesToAdd,
                onAdd: { type, reason, frequency in
                    Task {
                        await viewModel.addAddiction(type: type, reason: reason, frequency: frequency)
                        onChange()
                    }
                },
                onCancel: { viewModel.isShowingAddFlow = false }
            )
        }
        .alert(
            "Sucht löschen?",
            isPresented: Binding(
                get: { pendingDeletion != nil },
                set: { if !$0 { pendingDeletion = nil } }
            )
        ) {
            Button("Löschen", role: .destructive) {
                if let target = pendingDeletion {
                    Task {
                        await viewModel.delete(target.id)
                        onChange()
                    }
                }
                pendingDeletion = nil
            }
            Button("Abbrechen", role: .cancel) { pendingDeletion = nil }
        } message: {
            Text("Alle Daten dieser Sucht (Streak, Journal, Rückfälle, Plan) werden dauerhaft gelöscht.")
        }
    }

    private func row(_ addiction: AddictionSummary, viewModel: AddictionManagerViewModel) -> some View {
        Button {
            Task {
                await viewModel.switchTo(addiction.id)
                onChange()
            }
        } label: {
            HStack(spacing: AppSpacing.m) {
                Text(addiction.emoji)
                    .font(.title2)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(addiction.title)
                        .font(AppFont.body.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text("\(addiction.currentStreakDays) Tage clean")
                        .font(AppFont.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if addiction.isActive {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppColor.accent)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(addiction.title), \(addiction.currentStreakDays) Tage clean")
        .accessibilityAddTraits(addiction.isActive ? [.isSelected] : [])
        .swipeActions(edge: .trailing) {
            // Löschen nur erlauben, wenn mehr als eine Sucht existiert.
            if viewModel.addictions.count > 1 {
                Button(role: .destructive) {
                    pendingDeletion = addiction
                } label: {
                    Label("Löschen", systemImage: "trash")
                }
            }
        }
    }
}

#Preview {
    AddictionManagerView()
}
