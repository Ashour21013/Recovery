import SwiftUI

/// Rückfall melden (Figma): ohne Wertung, Trigger-Chips, Stärke, Notiz,
/// coral „Neustart festhalten“ und anschließender Ermutigungs-Screen.
struct RelapseView: View {

    @Environment(\.dependencies) private var dependencies
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: RelapseViewModel?
    @State private var isConfirming = false
    @State private var didFinish = false

    let onSaved: () -> Void

    var body: some View {
        NavigationStack {
            Group {
                if didFinish {
                    successView
                        .transition(.scale(scale: 0.95).combined(with: .opacity))
                } else if let viewModel {
                    form(viewModel)
                } else {
                    ProgressView()
                }
            }
            .animation(.smooth, value: didFinish)
            .background(AppColor.background.ignoresSafeArea())
            .toolbar {
                if !didFinish {
                    ToolbarItem(placement: .cancellationAction) {
                        Button { dismiss() } label: { Image(systemName: "xmark") }
                            .accessibilityLabel("Schließen")
                    }
                }
            }
        }
        .tint(AppColor.teal)
        .task {
            if viewModel == nil {
                viewModel = RelapseViewModel(repository: dependencies.makeRecoveryRepository())
            }
            await viewModel?.onAppear()
        }
        .confirmationDialog("Neustart festhalten?", isPresented: $isConfirming, titleVisibility: .visible) {
            Button("Neustart festhalten", role: .destructive) { Task { await confirmSave() } }
            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text("Deine aktuelle Streak beginnt neu. Deine längste Streak bleibt erhalten.")
        }
    }

    private func form(_ viewModel: RelapseViewModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Eyebrow(String(localized: "Ohne Wertung"), color: AppColor.coral)
                Text("Ein Rückfall ist kein Scheitern.")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(AppColor.ink)
                    .padding(.top, 4)
                Text("Lass uns kurz festhalten, was passiert ist. Das hilft dir, deine Muster besser zu verstehen.")
                    .font(.footnote)
                    .foregroundStyle(AppColor.muted)
                    .padding(.top, 8)

                sectionTitle(String(localized: "Was war der Auslöser?"))
                FlowLayout {
                    ForEach(viewModel.suggestedTriggers, id: \.self) { name in
                        SelectableChip(title: name, isSelected: viewModel.isSelected(name),
                                       tone: Color(hex: 0xA95240), toneSoft: AppColor.coralSoft) {
                            viewModel.toggleTrigger(name)
                        }
                    }
                }
                HStack(spacing: 8) {
                    TextField("Eigener Auslöser …", text: Binding(
                        get: { viewModel.newTriggerName }, set: { viewModel.newTriggerName = $0 }))
                        .font(.footnote)
                        .onSubmit(viewModel.addCustomTrigger)
                    Button(action: viewModel.addCustomTrigger) {
                        Image(systemName: "plus")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(AppColor.coral))
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.newTriggerName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.leading, 12)
                .padding(4)
                .background(RoundedRectangle(cornerRadius: 13, style: .continuous).fill(AppColor.surface))
                .overlay(RoundedRectangle(cornerRadius: 13, style: .continuous).stroke(AppColor.line))
                .padding(.top, 9)

                sectionTitle(String(localized: "Wie stark war das Verlangen?"))
                HStack {
                    Slider(value: Binding(
                        get: { Double(viewModel.cravingIntensity) },
                        set: { viewModel.cravingIntensity = Int($0.rounded()) }
                    ), in: 1...10, step: 1)
                    .tint(AppColor.coral)
                    Text("\(viewModel.cravingIntensity)/10")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(AppColor.coral)
                        .monospacedDigit()
                        .frame(width: 48)
                }

                sectionTitle(String(localized: "Wann ist es passiert?"))
                DatePicker("Zeitpunkt", selection: Binding(
                    get: { viewModel.date }, set: { viewModel.date = $0 }), in: ...Date.now)
                    .font(.footnote)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(AppColor.surface))
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(AppColor.line))

                HStack {
                    sectionTitle(String(localized: "Möchtest du etwas notieren?"))
                    Spacer()
                    Text("Optional").font(.caption2).foregroundStyle(AppColor.muted).padding(.top, 18)
                }
                AppTextEditor(
                    placeholder: String(localized: "Was möchtest du dir merken?"),
                    text: Binding(get: { viewModel.note }, set: { viewModel.note = $0 }),
                    minHeight: 80
                )
                .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(AppColor.surface))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(AppColor.line))

                Button("Neustart festhalten") { isConfirming = true }
                    .buttonStyle(TealButtonStyle(fill: AppColor.coral))
                    .padding(.top, 20)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 28)
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.subheadline.weight(.bold))
            .foregroundStyle(AppColor.ink)
            .padding(.top, 18)
            .padding(.bottom, 9)
    }

    private var successView: some View {
        VStack(spacing: 0) {
            Spacer()
            Image(systemName: "heart.fill")
                .font(.system(size: 34))
                .foregroundStyle(AppColor.coral)
                .frame(width: 86, height: 86)
                .background(Circle().fill(AppColor.coralSoft))
                .background(Circle().fill(AppColor.coral.opacity(0.06)).padding(-15))
                .symbolEffect(.bounce, value: didFinish)
                .padding(.bottom, 30)
            Text("Jeder Neustart zählt.")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(AppColor.ink)
            Text("Danke, dass du ehrlich zu dir warst. Morgen ist kein Rückschritt – sondern ein neuer Anfang.")
                .font(.subheadline)
                .lineSpacing(3)
                .foregroundStyle(AppColor.muted)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
            Spacer()
            Button("Zurück zu Heute") { onSaved(); dismiss() }
                .buttonStyle(TealButtonStyle())
        }
        .padding(28)
    }

    private func confirmSave() async {
        guard let viewModel else { return }
        await viewModel.save()
        if viewModel.didSave {
            didFinish = true
        }
    }
}

#Preview {
    RelapseView(onSaved: {})
}
