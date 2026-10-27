import SwiftUI
import FamilyControls

/// Einstellungs-Screen des Inhaltsschutzes (Pornografie-Filter).
///
/// Aktivieren mit Bildschirmzeit-Berechtigung, eigene Domains, App-Sperren
/// und eine bewusste Hürde (Countdown) beim Abschalten.
struct ContentBlockingView: View {

    @Environment(\.dependencies) private var dependencies
    @State private var viewModel: ContentBlockingViewModel?

    var body: some View {
        Group {
            if let viewModel {
                form(viewModel)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Inhaltsschutz")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel == nil {
                viewModel = ContentBlockingViewModel(
                    service: dependencies.contentBlockingService,
                    store: dependencies.contentBlockingSettingsStore
                )
            }
            viewModel?.onAppear()
        }
    }

    // MARK: - Formular

    private func form(_ viewModel: ContentBlockingViewModel) -> some View {
        @Bindable var viewModel = viewModel
        return Form {
            statusSection(viewModel)

            if viewModel.isSimulated {
                Section {
                    Label {
                        Text("Simulator-Modus: Bildschirmzeit ist hier nicht verfügbar. Der Ablauf wird nur simuliert, es wird nichts gesperrt. Teste auf einem echten iPhone.")
                            .font(AppFont.caption)
                    } icon: {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.orange)
                    }
                }
            }

            if viewModel.isEnabled {
                domainsSection(viewModel)
                appsSection(viewModel)
                deactivationSection(viewModel)
            } else {
                explanationSection
            }
        }
        .familyActivityPicker(
            isPresented: $viewModel.isShowingAppPicker,
            selection: $viewModel.selection
        )
        .onChange(of: viewModel.selection) {
            viewModel.selectionDidChange()
        }
        .alert(
            "Hinweis",
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

    // MARK: - Sektionen

    private func statusSection(_ viewModel: ContentBlockingViewModel) -> some View {
        Section {
            HStack(spacing: AppSpacing.m) {
                Image(systemName: viewModel.isEnabled ? "checkmark.shield.fill" : "shield.slash")
                    .font(.title2)
                    .foregroundStyle(viewModel.isEnabled ? AppColor.success : .secondary)
                    .frame(width: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.isEnabled ? "Schutz aktiv" : "Schutz inaktiv")
                        .font(AppFont.headline)
                    Text(viewModel.isEnabled
                         ? "Websites für Erwachsene werden blockiert."
                         : "Blockiere pornografische Inhalte auf diesem iPhone.")
                        .font(AppFont.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, AppSpacing.xs)

            if !viewModel.isEnabled {
                Button {
                    Task { await viewModel.enable() }
                } label: {
                    HStack {
                        Spacer()
                        if viewModel.isWorking {
                            ProgressView()
                        } else {
                            Text("Schutz aktivieren")
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                }
                .disabled(viewModel.isWorking)
            }
        }
    }

    private var explanationSection: some View {
        Section("So funktioniert's") {
            Label("Nutzt Apples Bildschirmzeit-Filter für Websites für Erwachsene – in Safari und in Apps mit Webinhalten.", systemImage: "globe")
            Label("Du kannst eigene Websites und Apps zusätzlich sperren.", systemImage: "plus.circle")
            Label("Abschalten ist nur nach einer Wartezeit möglich – das schützt dich in schwachen Momenten.", systemImage: "hourglass")
            Label("Deine Daten verlassen das Gerät nicht.", systemImage: "lock.fill")
        }
        .font(AppFont.subheadline)
    }

    private func domainsSection(_ viewModel: ContentBlockingViewModel) -> some View {
        @Bindable var viewModel = viewModel
        return Section {
            HStack {
                TextField("beispiel.com", text: $viewModel.newDomainInput)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
                    .onSubmit { viewModel.addDomain() }
                Button("Hinzufügen") { viewModel.addDomain() }
                    .disabled(viewModel.newDomainInput.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            ForEach(viewModel.customDomains, id: \.self) { domain in
                Label(domain, systemImage: "nosign")
            }
            .onDelete { viewModel.removeDomains(at: $0) }
        } header: {
            Text("Zusätzliche Websites")
        } footer: {
            Text("Diese Websites werden zusätzlich zum automatischen Filter blockiert.")
        }
    }

    private func appsSection(_ viewModel: ContentBlockingViewModel) -> some View {
        Section {
            Button {
                viewModel.isShowingAppPicker = true
            } label: {
                HStack {
                    Label("Apps & Websites auswählen", systemImage: "apps.iphone")
                    Spacer()
                    Text(viewModel.selectionSummary)
                        .font(AppFont.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("Apps sperren")
        } footer: {
            Text("Gesperrte Apps zeigen beim Öffnen einen Sperrbildschirm.")
        }
    }

    @ViewBuilder
    private func deactivationSection(_ viewModel: ContentBlockingViewModel) -> some View {
        Section {
            if let countdown = viewModel.countdown {
                VStack(alignment: .leading, spacing: AppSpacing.s) {
                    Text(countdown.isFinished
                         ? "Du kannst den Schutz jetzt abschalten."
                         : "Atme durch. Willst du das wirklich? Noch \(countdown.remaining) s")
                        .font(AppFont.subheadline)
                    ProgressView(value: countdown.progress)
                        .tint(.orange)
                }
                .padding(.vertical, AppSpacing.xs)

                Button("Schutz abschalten", role: .destructive) {
                    viewModel.confirmDeactivation()
                }
                .disabled(!countdown.isFinished)

                Button("Doch aktiv lassen") {
                    viewModel.cancelDeactivation()
                }
                .fontWeight(.semibold)
            } else {
                Button("Schutz abschalten …", role: .destructive) {
                    viewModel.startDeactivation()
                }
            }
        } footer: {
            Text("Zum Abschalten läuft eine Wartezeit von \(DeactivationCountdown.defaultDuration) Sekunden.")
        }
    }
}

#Preview {
    NavigationStack {
        ContentBlockingView()
    }
}
