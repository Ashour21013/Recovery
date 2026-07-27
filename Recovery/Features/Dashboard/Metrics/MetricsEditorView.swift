import SwiftUI

/// Editor zum Erfassen der Fortschritts-Metriken der aktiven Sucht.
///
/// Zeigt je nach Metrik-Kategorie unterschiedliche Felder (Geld vs. Zeit).
/// Bindet an `MetricsEditorViewModel` und greift nie direkt auf SwiftData zu.
struct MetricsEditorView: View {

    @Environment(\.dependencies) private var dependencies
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: MetricsEditorViewModel?

    /// Wird nach erfolgreichem Speichern aufgerufen (Dashboard neu laden).
    var onSaved: () -> Void = {}

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    form(viewModel)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Deine Werte")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        Task {
                            if await viewModel?.save() == true {
                                onSaved()
                                dismiss()
                            }
                        }
                    }
                }
            }
        }
        .task {
            if viewModel == nil {
                viewModel = MetricsEditorViewModel(
                    repository: dependencies.makeRecoveryRepository()
                )
            }
            await viewModel?.onAppear()
        }
    }

    @ViewBuilder
    private func form(_ viewModel: MetricsEditorViewModel) -> some View {
        Form {
            switch viewModel.category {
            case .money:
                moneySection(viewModel)
            case .time:
                timeSection(viewModel)
            }
        }
    }

    // MARK: - Geld-Süchte

    @ViewBuilder
    private func moneySection(_ viewModel: MetricsEditorViewModel) -> some View {
        Section {
            LabeledField(
                title: "Preis pro Packung (€)",
                text: bindingUnitPrice(viewModel),
                placeholder: "z. B. 7,00"
            )
            LabeledField(
                title: "\(viewModel.consumptionUnitName) pro Tag",
                text: bindingUnitsPerDay(viewModel),
                placeholder: "z. B. 15"
            )
            LabeledField(
                title: "Einheiten pro Packung",
                text: bindingUnitsPerPackage(viewModel),
                placeholder: "z. B. 20"
            )
        } header: {
            Text("Kosten pro Packung")
        } footer: {
            Text("Alternativ kannst du unten direkt deine Wochenausgaben angeben.")
        }

        Section("Oder: Wochenausgaben") {
            LabeledField(
                title: "Ausgaben pro Woche (€)",
                text: bindingWeeklySpend(viewModel),
                placeholder: "z. B. 50,00"
            )
        }
    }

    // MARK: - Zeit-Süchte

    private func timeSection(_ viewModel: MetricsEditorViewModel) -> some View {
        Section {
            LabeledField(
                title: "Minuten pro Tag",
                text: bindingMinutesPerDay(viewModel),
                placeholder: "z. B. 90"
            )
        } header: {
            Text("Verbrauchte Zeit")
        } footer: {
            Text("Schätze, wie viel Zeit du früher durchschnittlich pro Tag investiert hast.")
        }
    }

    // MARK: - Bindings (Text-Felder)

    private func bindingUnitPrice(_ vm: MetricsEditorViewModel) -> Binding<String> {
        Binding(get: { vm.unitPriceText }, set: { vm.unitPriceText = $0 })
    }
    private func bindingUnitsPerDay(_ vm: MetricsEditorViewModel) -> Binding<String> {
        Binding(get: { vm.unitsPerDayText }, set: { vm.unitsPerDayText = $0 })
    }
    private func bindingUnitsPerPackage(_ vm: MetricsEditorViewModel) -> Binding<String> {
        Binding(get: { vm.unitsPerPackageText }, set: { vm.unitsPerPackageText = $0 })
    }
    private func bindingWeeklySpend(_ vm: MetricsEditorViewModel) -> Binding<String> {
        Binding(get: { vm.weeklySpendText }, set: { vm.weeklySpendText = $0 })
    }
    private func bindingMinutesPerDay(_ vm: MetricsEditorViewModel) -> Binding<String> {
        Binding(get: { vm.minutesPerDayText }, set: { vm.minutesPerDayText = $0 })
    }
}

/// Kleine, wiederverwendbare beschriftete Zahleneingabe.
private struct LabeledField: View {
    let title: String
    @Binding var text: String
    let placeholder: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            TextField(placeholder, text: $text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 120)
        }
    }
}

#Preview {
    MetricsEditorView()
}
