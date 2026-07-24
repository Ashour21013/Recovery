import SwiftUI

/// Screen zur Konfiguration der täglichen Erinnerungen.
///
/// Bindet an das `ReminderSettingsViewModel` (MVVM) und enthält keine
/// Benachrichtigungs- oder Persistenzlogik.
struct ReminderSettingsView: View {

    @Environment(\.dependencies) private var dependencies
    @State private var viewModel: ReminderSettingsViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    form(viewModel)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Erinnerungen")
        }
        .task {
            if viewModel == nil {
                viewModel = ReminderSettingsViewModel(
                    service: dependencies.notificationService,
                    store: dependencies.reminderSettingsStore
                )
            }
            await viewModel?.onAppear()
        }
    }

    private func form(_ viewModel: ReminderSettingsViewModel) -> some View {
        Form {
            Section {
                ForEach(ReminderTime.allCases) { time in
                    Toggle(isOn: binding(for: time, viewModel: viewModel)) {
                        Label(time.title, systemImage: time.systemImage)
                    }
                }
            } header: {
                Text("Tägliche Erinnerungen")
            } footer: {
                Text("Wir senden dir zu den gewählten Zeiten eine motivierende Nachricht.")
            }

            if viewModel.isPermissionDenied {
                Section {
                    permissionWarning
                }
            }
        }
    }

    private var permissionWarning: some View {
        VStack(alignment: .leading, spacing: AppSpacing.s) {
            Label("Benachrichtigungen deaktiviert", systemImage: "bell.slash.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.orange)
            Text("Aktiviere Benachrichtigungen in den Einstellungen, um Erinnerungen zu erhalten.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            if let url = URL(string: UIApplication.openSettingsURLString) {
                Link("Einstellungen öffnen", destination: url)
                    .font(.footnote.weight(.semibold))
            }
        }
    }

    private func binding(
        for time: ReminderTime,
        viewModel: ReminderSettingsViewModel
    ) -> Binding<Bool> {
        Binding(
            get: { viewModel.isEnabled(time) },
            set: { _ in Task { await viewModel.toggle(time) } }
        )
    }
}

#Preview {
    ReminderSettingsView()
}
