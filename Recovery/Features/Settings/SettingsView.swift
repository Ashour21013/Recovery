import SwiftUI
import UIKit

/// Einstellungen-Screen der App.
///
/// Bündelt Datenschutz, Benachrichtigungen/Erinnerungen, Feedback,
/// rechtliche Links sowie die Datenverwaltung (Export/Löschen). Bindet an
/// das `SettingsViewModel` (MVVM) und enthält keine Persistenzlogik.
struct SettingsView: View {

    @Environment(\.dependencies) private var dependencies
    @Environment(\.openURL) private var openURL
    @State private var viewModel: SettingsViewModel?
    @State private var isShowingPaywall = false
    @State private var isShowingMetricsEditor = false

    /// Wird aufgerufen, wenn alle Daten gelöscht wurden (App-Reset).
    var onDataDeleted: () -> Void = {}

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    form(viewModel)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Einstellungen")
        }
        .task {
            if viewModel == nil {
                viewModel = SettingsViewModel(
                    repository: dependencies.makeRecoveryRepository(),
                    subscriptionService: dependencies.subscriptionService
                )
            }
        }
    }

    // MARK: - Formular

    private func form(_ viewModel: SettingsViewModel) -> some View {
        Form {
            subscriptionSection(viewModel)
            privacySection
            trackingSection
            notificationsSection
            dataSection(viewModel)
            supportSection(viewModel)
            aboutSection(viewModel)
        }
        .sheet(isPresented: $isShowingPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $isShowingMetricsEditor) {
            MetricsEditorView()
        }
        .sheet(isPresented: Binding(
            get: { viewModel.exportURL != nil },
            set: { if !$0 { viewModel.clearExport() } }
        )) {
            if let url = viewModel.exportURL {
                ShareSheet(items: [url])
            }
        }
        .confirmationDialog(
            "Alle Daten löschen?",
            isPresented: Binding(
                get: { viewModel.isConfirmingDeletion },
                set: { viewModel.isConfirmingDeletion = $0 }
            ),
            titleVisibility: .visible
        ) {
            Button("Alle Daten löschen", role: .destructive) {
                Task {
                    await viewModel.confirmDeletion()
                    if viewModel.didDeleteAllData { onDataDeleted() }
                }
            }
            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text("Dieser Vorgang kann nicht rückgängig gemacht werden. Alle Einträge, Trigger, Rückfälle und Erfolge werden dauerhaft gelöscht.")
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
        .alert(
            "Hinweis",
            isPresented: Binding(
                get: { viewModel.infoMessage != nil },
                set: { if !$0 { viewModel.infoMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.infoMessage ?? "")
        }
    }

    // MARK: - Sektionen

    /// Abonnement-/Premium-Sektion.
    ///
    /// Für ALLE Nutzer sichtbar und bedienbar (auch für Premium-Nutzer) –
    /// insbesondere ist "Käufe wiederherstellen" immer erreichbar
    /// (App-Store-Richtlinie). Diese Sektion liegt bewusst NICHT hinter dem
    /// Premium-Gate.
    private func subscriptionSection(_ viewModel: SettingsViewModel) -> some View {
        Section {
            // Status-Zeile.
            HStack(spacing: AppSpacing.m) {
                Image(systemName: "crown.fill")
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(AppColor.accent.gradient)
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.isPremium ? "Premium aktiv" : "Kostenlose Version")
                        .font(AppFont.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(viewModel.isPremium
                         ? "Vielen Dank für deine Unterstützung!"
                         : "Alle Funktionen freischalten")
                        .font(AppFont.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if viewModel.isPremium {
                    Text("Aktiv")
                        .font(AppFont.caption.weight(.semibold))
                        .foregroundStyle(AppColor.success)
                }
            }

            // Für Free-Nutzer: Premium freischalten (öffnet Paywall).
            if !viewModel.isPremium {
                Button {
                    isShowingPaywall = true
                } label: {
                    HStack {
                        settingsLabel("Premium freischalten", systemImage: "sparkles", tint: AppColor.accent)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                }
                .buttonStyle(.plain)
            }

            // Käufe wiederherstellen – IMMER anklickbar (kein Premium-Gate).
            Button {
                Task { await viewModel.restorePurchases() }
            } label: {
                HStack {
                    settingsLabel("Käufe wiederherstellen", systemImage: "arrow.clockwise", tint: .blue)
                    Spacer()
                    if viewModel.isRestoring {
                        ProgressView()
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isRestoring)

            // Für Premium-Nutzer: Abo verwalten (System-Verwaltung).
            if viewModel.isPremium {
                Button {
                    openURL(AppLinks.manageSubscriptions)
                } label: {
                    HStack {
                        settingsLabel("Abonnement verwalten", systemImage: "gearshape.fill", tint: .gray)
                        Spacer()
                        Image(systemName: "arrow.up.forward.app")
                            .foregroundStyle(.tertiary)
                    }
                }
                .buttonStyle(.plain)
            }
        } header: {
            Text("Abonnement")
        } footer: {
            Text("Käufe wiederherstellen ist immer verfügbar – z. B. nach einem Gerätewechsel oder einer Neuinstallation.")
        }
    }

    private var privacySection: some View {        Section {
            NavigationLink {
                PrivacyView()
            } label: {
                settingsLabel("Datenschutz", systemImage: "lock.shield.fill", tint: .blue)
            }
        }
    }

    private var trackingSection: some View {
        Section("Fortschritt") {
            Button {
                isShowingMetricsEditor = true
            } label: {
                HStack {
                    settingsLabel("Deine Werte", systemImage: "chart.line.uptrend.xyaxis", tint: .green)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var notificationsSection: some View {
        Section("Benachrichtigungen") {
            NavigationLink {
                ReminderSettingsView()
            } label: {
                settingsLabel("Erinnerungen", systemImage: "bell.badge.fill", tint: .orange)
            }
            Button {
                openSystemNotificationSettings()
            } label: {
                HStack {
                    settingsLabel("Systembenachrichtigungen", systemImage: "gearshape.fill", tint: .gray)
                    Spacer()
                    Image(systemName: "arrow.up.forward.app")
                        .foregroundStyle(.tertiary)
                }
            }
            .buttonStyle(.plain)
        }
    }

    private func dataSection(_ viewModel: SettingsViewModel) -> some View {
        Section {
            Button {
                Task { await viewModel.exportData() }
            } label: {
                HStack {
                    settingsLabel("Daten exportieren", systemImage: "square.and.arrow.up.fill", tint: .green)
                    Spacer()
                    if viewModel.isExporting {
                        ProgressView()
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isExporting)

            Button(role: .destructive) {
                viewModel.requestDeletion()
            } label: {
                settingsLabel("Alle Daten löschen", systemImage: "trash.fill", tint: .red)
            }
        } header: {
            Text("Daten")
        } footer: {
            Text("Exportiere deine Daten als JSON-Datei oder lösche sie unwiderruflich.")
        }
    }

    private func supportSection(_ viewModel: SettingsViewModel) -> some View {
        Section("Support") {
            Button {
                sendFeedback()
            } label: {
                settingsLabel("Feedback senden", systemImage: "envelope.fill", tint: .teal)
            }
            .buttonStyle(.plain)

            Button {
                openURL(AppLinks.appStoreReview)
            } label: {
                settingsLabel("App bewerten", systemImage: "star.fill", tint: .yellow)
            }
            .buttonStyle(.plain)

            Button {
                openURL(AppLinks.privacyPolicy)
            } label: {
                settingsLabel("Datenschutzrichtlinie", systemImage: "doc.text.fill", tint: .indigo)
            }
            .buttonStyle(.plain)
        }
    }

    private func aboutSection(_ viewModel: SettingsViewModel) -> some View {
        Section {
            HStack {
                settingsLabel("Version", systemImage: "info.circle.fill", tint: .secondary)
                Spacer()
                Text(viewModel.appVersion)
                    .foregroundStyle(.secondary)
            }
        } footer: {
            Text("Recovery – dein Begleiter auf dem Weg zu einem freieren Leben. Mit ❤️ entwickelt.")
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, AppSpacing.s)
        }
    }

    // MARK: - Bausteine

    private func settingsLabel(_ title: String, systemImage: String, tint: Color) -> some View {
        Label {
            Text(title)
                .foregroundStyle(.primary)
        } icon: {
            Image(systemName: systemImage)
                .font(.footnote)
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(tint)
                )
        }
    }

    // MARK: - Aktionen

    private func sendFeedback() {
        if let url = AppLinks.feedbackMailto {
            openURL(url)
        }
    }

    private func openSystemNotificationSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            openURL(url)
        }
    }
}

#Preview {
    SettingsView()
}
