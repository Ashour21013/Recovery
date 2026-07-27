import SwiftUI
import StoreKit

/// Paywall-Screen zur Vorstellung und zum Kauf von Recovery Premium.
///
/// Zeigt die Premium-Vorteile, die drei Produkte (mit hervorgehobener
/// Empfehlung und Testphase), einen Kauf- und Restore-Button sowie Links zu
/// Datenschutz und AGB. Bindet an das `PaywallViewModel` (MVVM).
struct PaywallView: View {

    @Environment(\.dependencies) private var dependencies
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var viewModel: PaywallViewModel?

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
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Recovery Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Schließen") { dismiss() }
                }
            }
        }
        .task {
            if viewModel == nil {
                viewModel = PaywallViewModel(service: dependencies.subscriptionService)
            }
            await viewModel?.onAppear()
        }
        .onChange(of: viewModel?.didCompletePurchase) { _, done in
            if done == true { dismiss() }
        }
    }

    @ViewBuilder
    private func content(_ viewModel: PaywallViewModel) -> some View {
        ScrollView {
            VStack(spacing: AppSpacing.l) {
                header
                benefits(viewModel.benefits)
                products(viewModel)
                purchaseSection(viewModel)
                legalLinks
            }
            .padding(AppSpacing.m)
        }
        .alert(
            "Hinweis",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: AppSpacing.s) {
            Image(systemName: "crown.fill")
                .font(.system(size: 52))
                .foregroundStyle(AppColor.accent.gradient)
                .accessibilityHidden(true)
            Text("Hol das Maximum aus deiner Reise")
                .font(AppFont.title2)
                .multilineTextAlignment(.center)
            Text("Schalte alle Funktionen frei und bleib motiviert.")
                .font(AppFont.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, AppSpacing.s)
    }

    // MARK: - Vorteile

    private func benefits(_ benefits: [PremiumBenefit]) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.m) {
            ForEach(benefits) { benefit in
                HStack(spacing: AppSpacing.m) {
                    Image(systemName: benefit.systemImage)
                        .font(.title3)
                        .foregroundStyle(AppColor.accent)
                        .frame(width: 32)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(benefit.title)
                            .font(AppFont.subheadline.weight(.semibold))
                        Text(benefit.subtitle)
                            .font(AppFont.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 0)
                }
                .accessibilityElement(children: .combine)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Produkte

    @ViewBuilder
    private func products(_ viewModel: PaywallViewModel) -> some View {
        if viewModel.displayProducts.isEmpty {
            ProgressView("Produkte werden geladen…")
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.l)
        } else {
            VStack(spacing: AppSpacing.s) {
                ForEach(viewModel.displayProducts, id: \.product.id) { info in
                    ProductOptionRow(
                        info: info,
                        isSelected: viewModel.selectedProductID == info.product.id,
                        action: { viewModel.select(info) }
                    )
                }
            }
        }
    }

    // MARK: - Kauf

    private func purchaseSection(_ viewModel: PaywallViewModel) -> some View {
        VStack(spacing: AppSpacing.s) {
            PrimaryButton(title: purchaseTitle(viewModel)) {
                Task { await viewModel.purchaseSelected() }
            }
            .disabled(viewModel.isLoading || viewModel.selectedProductID == nil)
            .opacity(viewModel.isLoading ? 0.6 : 1)

            Button("Käufe wiederherstellen") {
                Task { await viewModel.restore() }
            }
            .font(AppFont.footnote)
            .disabled(viewModel.isLoading)

            if viewModel.hasAnyFreeTrial {
                Text("Jederzeit kündbar. Die Testphase wird automatisch in ein Abo umgewandelt, wenn du nicht kündigst.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private func purchaseTitle(_ viewModel: PaywallViewModel) -> String {
        let selected = viewModel.displayProducts.first { $0.product.id == viewModel.selectedProductID }
        if let selected, selected.hasFreeTrial {
            return "Kostenlos testen"
        }
        return "Fortfahren"
    }

    // MARK: - Rechtliches

    private var legalLinks: some View {
        HStack(spacing: AppSpacing.m) {
            Button("Datenschutz") { openURL(AppLinks.privacyPolicy) }
            Text("·").foregroundStyle(.secondary)
            Button("AGB") { openURL(AppLinks.termsOfService) }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(.top, AppSpacing.s)
    }
}

#Preview {
    PaywallView()
}
