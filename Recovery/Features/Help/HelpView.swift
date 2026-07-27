import SwiftUI

/// Hilfe- & Ressourcen-Screen.
///
/// Zeigt appeigene Selbsthilfe-Werkzeuge sowie offizielle, externe
/// Beratungsangebote (nach Region gruppiert) und einen deutlich sichtbaren
/// rechtlichen Hinweis. Bindet an das `HelpViewModel` (MVVM) und enthält
/// keine Geschäftslogik.
struct HelpView: View {

    @Environment(\.dependencies) private var dependencies
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: HelpViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    content(viewModel)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Hilfe & Ressourcen")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Schließen") { dismiss() }
                }
            }
        }
        .task {
            if viewModel == nil {
                viewModel = HelpViewModel(provider: dependencies.helpResourceProvider)
            }
            viewModel?.onAppear()
        }
    }

    @ViewBuilder
    private func content(_ viewModel: HelpViewModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.l) {
                disclaimerBanner(viewModel.disclaimer)

                section(
                    title: "In der App",
                    subtitle: "Werkzeuge, die dir sofort helfen können.",
                    resources: viewModel.inAppResources,
                    onTap: viewModel.handleInAppTap
                )

                ForEach(viewModel.externalSections) { sectionData in
                    section(
                        title: sectionData.region.title,
                        subtitle: nil,
                        resources: sectionData.resources,
                        onTap: nil
                    )
                }
            }
            .padding(AppSpacing.m)
        }
        .sheet(isPresented: Binding(
            get: { viewModel.isShowingCravingMode },
            set: { viewModel.isShowingCravingMode = $0 }
        )) {
            CravingModeView()
        }
    }

    // MARK: - Bausteine

    private func disclaimerBanner(_ text: String) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.s) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
                .accessibilityHidden(true)
            Text(text)
                .font(AppFont.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AppSpacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.orange.opacity(0.12))
        )
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func section(
        title: String,
        subtitle: String?,
        resources: [HelpResource],
        onTap: ((HelpResource) -> Void)?
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.s) {
            Text(title)
                .font(AppFont.headline)
            if let subtitle {
                Text(subtitle)
                    .font(AppFont.footnote)
                    .foregroundStyle(.secondary)
            }
            ForEach(resources) { resource in
                HelpResourceCard(
                    resource: resource,
                    onTap: onTap.map { handler in { handler(resource) } }
                )
            }
        }
    }
}

#Preview {
    HelpView()
}
