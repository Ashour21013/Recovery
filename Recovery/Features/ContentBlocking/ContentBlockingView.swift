import SwiftUI
import FamilyControls

/// Inhaltsschutz im Figma-Design: Status-Karte, Erklärung, Domains,
/// App-Auswahl und bewusster Countdown beim Abschalten.
struct ContentBlockingView: View {

    @Environment(\.dependencies) private var dependencies
    @State private var viewModel: ContentBlockingViewModel?

    var body: some View {
        Group {
            if let viewModel {
                content(viewModel)
            } else {
                ProgressView()
            }
        }
        .background(AppColor.background.ignoresSafeArea())
        .navigationTitle("Inhaltsschutz")
        .navigationBarTitleDisplayMode(.inline)
        .tint(AppColor.teal)
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

    private func content(_ viewModel: ContentBlockingViewModel) -> some View {
        @Bindable var viewModel = viewModel
        return ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                statusCard(viewModel)

                if viewModel.isSimulated {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "info.circle.fill").foregroundStyle(AppColor.gold)
                        Text("Simulator-Modus: Bildschirmzeit ist hier nicht verfügbar. Der Ablauf wird nur simuliert. Teste auf einem echten iPhone.")
                            .font(.caption)
                            .foregroundStyle(AppColor.muted)
                    }
                    .figmaCard(radius: 14, padding: 13)
                    .padding(.top, 12)
                }

                if !viewModel.isEnabled {
                    Button {
                        Task { await viewModel.enable() }
                    } label: {
                        HStack(spacing: 8) {
                            if viewModel.isWorking {
                                ProgressView().tint(.white)
                                Text("Wird vorbereitet …")
                            } else {
                                Image(systemName: "shield")
                                Text("Schutz aktivieren")
                            }
                        }
                    }
                    .buttonStyle(TealButtonStyle())
                    .disabled(viewModel.isWorking)
                    .padding(.top, 13)

                    howItWorks
                } else if let countdown = viewModel.countdown {
                    countdownCard(countdown, viewModel: viewModel)
                } else {
                    domainsSection(viewModel)
                    sectionHeader(String(localized: "Apps sperren"))
                    Button { viewModel.isShowingAppPicker = true } label: {
                        iosRow(icon: "apps.iphone", tone: AppColor.purple, toneSoft: AppColor.purpleSoft,
                               title: String(localized: "Apps & Websites auswählen"), detail: viewModel.selectionSummary)
                    }
                    .buttonStyle(.plain)

                    sectionHeader(String(localized: "Schutz abschalten"))
                    Button { viewModel.startDeactivation() } label: {
                        iosRow(icon: "clock", tone: AppColor.coral, toneSoft: AppColor.coralSoft,
                               title: String(localized: "Schutz abschalten …"), detail: String(localized: "Mit bewusster Wartezeit"),
                               titleColor: Color(hex: 0xB76855))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 16)
            .padding(.bottom, 40)
            .animation(.smooth, value: viewModel.isEnabled)
            .animation(.smooth, value: viewModel.countdown == nil)
        }
        .familyActivityPicker(isPresented: $viewModel.isShowingAppPicker, selection: $viewModel.selection)
        .onChange(of: viewModel.selection) { viewModel.selectionDidChange() }
        .alert("Hinweis", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    // MARK: - Bausteine

    private func statusCard(_ viewModel: ContentBlockingViewModel) -> some View {
        let active = viewModel.isEnabled
        return HStack(spacing: 14) {
            ZStack(alignment: .bottomTrailing) {
                Image(systemName: active ? "shield.fill" : "shield.slash.fill")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(active ? AppColor.green : Color(hex: 0x8666AD))
                    .frame(width: 54, height: 54)
                    .background(RoundedRectangle(cornerRadius: 17, style: .continuous)
                        .fill(active ? AppColor.greenSoft : AppColor.purpleSoft))
                    .contentTransition(.symbolEffect(.replace))
                if active {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(AppColor.green)
                        .frame(width: 19, height: 19)
                        .background(Circle().fill(.white))
                        .offset(x: -4, y: -4)
                        .transition(.scale)
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(active ? String(localized: "Schutz aktiv") : String(localized: "Schutz inaktiv"))
                    .font(.title3.weight(.bold))
                    .foregroundStyle(AppColor.ink)
                Text(active ? String(localized: "Inhalte für Erwachsene werden blockiert.")
                            : String(localized: "Pornografische Websites werden derzeit nicht gefiltert."))
                    .font(.caption)
                    .foregroundStyle(AppColor.muted)
            }
        }
        .frame(minHeight: 62)
        .figmaCard(radius: 20, padding: 16)
    }

    private var howItWorks: some View {
        VStack(alignment: .leading, spacing: 0) {
            Eyebrow(String(localized: "So funktioniert’s"))
                .padding(.horizontal, 13)
                .padding(.top, 13)
                .padding(.bottom, 6)
            ForEach([
                ("shield", String(localized: "Nutzt Apples Bildschirmzeit-Filter für Websites für Erwachsene")),
                ("plus", String(localized: "Eigene Websites und Apps zusätzlich sperren")),
                ("clock", String(localized: "Abschalten nur nach einer Wartezeit – schützt in schwachen Momenten")),
                ("lock", String(localized: "Deine Daten verlassen das Gerät nicht"))
            ], id: \.1) { icon, text in
                HStack(spacing: 11) {
                    IconTile(systemImage: icon, foreground: AppColor.purple, background: AppColor.purpleSoft, size: 31)
                    Text(text).font(.footnote).foregroundStyle(AppColor.ink)
                    Spacer(minLength: 0)
                }
                .frame(minHeight: 58)
                .padding(.trailing, 13)
                .overlay(alignment: .top) { Rectangle().fill(AppColor.line).frame(height: 1) }
                .padding(.leading, 13)
            }
        }
        .gainSurface(radius: 18)
        .padding(.top, 25)
    }

    private func domainsSection(_ viewModel: ContentBlockingViewModel) -> some View {
        @Bindable var viewModel = viewModel
        return VStack(alignment: .leading, spacing: 0) {
            sectionHeader(String(localized: "Zusätzliche Websites"))
            HStack(spacing: 7) {
                TextField("beispiel.com", text: $viewModel.newDomainInput)
                    .font(.footnote)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
                    .onSubmit { viewModel.addDomain() }
                    .padding(.horizontal, 4)
                Button("Hinzufügen") { viewModel.addDomain() }
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 11)
                    .frame(minHeight: 35)
                    .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(AppColor.teal))
                    .disabled(viewModel.newDomainInput.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .figmaCard(radius: 16, padding: 9)

            if !viewModel.customDomains.isEmpty {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.customDomains.enumerated()), id: \.element) { index, domain in
                        HStack(spacing: 9) {
                            Image(systemName: "shield").foregroundStyle(AppColor.purple)
                            Text(domain).font(.footnote.weight(.bold)).foregroundStyle(AppColor.ink)
                            Spacer()
                            Button {
                                viewModel.removeDomains(at: IndexSet(integer: index))
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(AppColor.muted)
                                    .frame(width: 30, height: 30)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(String(localized: "\(domain) löschen"))
                        }
                        .padding(.horizontal, 9)
                        .frame(minHeight: 48)
                        .overlay(alignment: .bottom) {
                            if index < viewModel.customDomains.count - 1 {
                                Rectangle().fill(AppColor.line).frame(height: 1)
                            }
                        }
                    }
                }
                .gainSurface(radius: 15)
                .padding(.top, 9)
            }
            Text("Diese Websites werden zusätzlich zum automatischen Filter blockiert.")
                .font(.caption2)
                .foregroundStyle(AppColor.muted)
                .padding(.horizontal, 10)
                .padding(.top, 7)
        }
    }

    private func countdownCard(_ countdown: DeactivationCountdown, viewModel: ContentBlockingViewModel) -> some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                Image(systemName: "clock")
                    .font(.system(size: 29, weight: .semibold))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Text("\(countdown.remaining)")
                    .font(.caption2.weight(.bold))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .padding(.bottom, 8)
            }
            .foregroundStyle(Color(hex: 0xC2775B))
            .frame(width: 78, height: 78)
            .background(Circle().fill(Color(light: 0xFBE9DF, dark: 0x4A3029)))
            .background(Circle().fill(Color(hex: 0xD7815F, opacity: 0.06)).padding(-13))
            .padding(.bottom, 28)

            Eyebrow(String(localized: "Ein Moment für dich"))
            Text(countdown.isFinished ? String(localized: "Du kannst den Schutz jetzt abschalten.") : String(localized: "Atme durch.\nWillst du das wirklich?"))
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(AppColor.ink)
                .multilineTextAlignment(.center)
                .padding(.vertical, 8)
            Text(countdown.isFinished
                 ? String(localized: "Was du jetzt entscheidest, ist in Ordnung. Du kannst den Schutz später wieder aktivieren.")
                 : String(localized: "Noch \(countdown.remaining) s. Diese Pause hilft dir, bewusst zu entscheiden."))
                .font(.caption)
                .foregroundStyle(AppColor.muted)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(light: 0xF4DFD6, dark: 0x4A3029))
                    Capsule().fill(Color(hex: 0xD68060))
                        .frame(width: geo.size.width * countdown.progress)
                        .animation(.linear(duration: 1), value: countdown.progress)
                }
            }
            .frame(height: 7)
            .padding(.vertical, 25)

            Button { viewModel.cancelDeactivation() } label: {
                Label("Doch aktiv lassen", systemImage: "shield")
            }
            .buttonStyle(TealButtonStyle())

            Button { viewModel.confirmDeactivation() } label: {
                Text(countdown.isFinished ? String(localized: "Schutz abschalten") : String(localized: "Schutz abschalten · \(countdown.remaining) s"))
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(countdown.isFinished ? Color(hex: 0xB76855) : AppColor.muted.opacity(0.6))
                    .frame(maxWidth: .infinity, minHeight: 46)
            }
            .buttonStyle(.plain)
            .disabled(!countdown.isFinished)
            .padding(.top, 7)
        }
        .padding(.horizontal, 18)
        .padding(.top, 32)
        .padding(.bottom, 18)
        .gainSurface(radius: AppRadius.card)
        .padding(.top, 14)
    }

    private func sectionHeader(_ text: String) -> some View {
        Eyebrow(text)
            .padding(.horizontal, 10)
            .padding(.top, 25)
            .padding(.bottom, 7)
    }

    private func iosRow(icon: String, tone: Color, toneSoft: Color, title: String,
                        detail: String, titleColor: Color = AppColor.ink) -> some View {
        HStack(spacing: 10) {
            IconTile(systemImage: icon, foreground: tone, background: toneSoft, size: 34)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.footnote.weight(.bold)).foregroundStyle(titleColor)
                Text(detail).font(.caption2).foregroundStyle(AppColor.muted)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppColor.muted)
        }
        .padding(.horizontal, 12)
        .frame(minHeight: 58)
        .gainSurface(radius: 16)
    }
}

#Preview {
    NavigationStack {
        ContentBlockingView()
    }
}
