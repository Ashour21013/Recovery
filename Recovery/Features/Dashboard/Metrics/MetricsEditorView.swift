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
            switch viewModel.inputLayout {
            case .smokingPackage:
                smokingSection(viewModel)
            case .alcoholWeekly:
                alcoholSection(viewModel)
            case .weeklySpendOnly:
                weeklySpendSection(viewModel)
            case .timePerDay:
                timeSection(viewModel)
            }
        }
    }

    // MARK: - Rauchen (Packungslogik)

    @ViewBuilder
    private func smokingSection(_ viewModel: MetricsEditorViewModel) -> some View {
        Section {
            LabeledField(
                title: "Preis pro Schachtel (€)",
                text: bindingUnitPrice(viewModel),
                placeholder: "z. B. 8,00"
            )
            LabeledField(
                title: "Zigaretten pro Tag",
                text: bindingUnitsPerDay(viewModel),
                placeholder: "z. B. 15"
            )
            LabeledField(
                title: "Zigaretten pro Schachtel",
                text: bindingUnitsPerPackage(viewModel),
                placeholder: "20"
            )
        } header: {
            Text("Deine Angaben")
        } footer: {
            Text("Daraus berechnen wir gespartes Geld und vermiedene Zigaretten.")
        }
    }

    // MARK: - Alkohol (Wochenausgabe + optional Getränke)

    @ViewBuilder
    private func alcoholSection(_ viewModel: MetricsEditorViewModel) -> some View {
        Section {
            LabeledField(
                title: "Ausgaben pro Woche (€)",
                text: bindingWeeklySpend(viewModel),
                placeholder: "z. B. 40,00"
            )
        } header: {
            Text("Ausgaben")
        }

        Section {
            LabeledField(
                title: "Getränke pro Woche",
                text: bindingDrinksPerWeek(viewModel),
                placeholder: "z. B. 14"
            )
        } header: {
            Text("Optional")
        } footer: {
            Text("Wenn du magst, sehen wir daraus auch deine vermiedenen Getränke.")
        }
    }

    // MARK: - Glücksspiel / Zucker (nur Wochenausgabe)

    @ViewBuilder
    private func weeklySpendSection(_ viewModel: MetricsEditorViewModel) -> some View {
        Section {
            LabeledField(
                title: weeklyLabel(viewModel),
                text: bindingWeeklySpend(viewModel),
                placeholder: "z. B. 30,00"
            )
        } header: {
            Text("Deine Angaben")
        } footer: {
            Text(weeklyFooter(viewModel))
        }
    }

    private func weeklyLabel(_ viewModel: MetricsEditorViewModel) -> String {
        viewModel.habitType == .gambling ? "Einsatz pro Woche (€)" : "Ausgaben pro Woche (€)"
    }

    private func weeklyFooter(_ viewModel: MetricsEditorViewModel) -> String {
        viewModel.habitType == .gambling
            ? "Daraus zeigen wir, wie viel du nicht verspielt hast."
            : "Optional – ohne Angabe zeigen wir dir deine Gesundheits-Meilensteine."
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
    private func bindingDrinksPerWeek(_ vm: MetricsEditorViewModel) -> Binding<String> {
        Binding(get: { vm.drinksPerWeekText }, set: { vm.drinksPerWeekText = $0 })
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
