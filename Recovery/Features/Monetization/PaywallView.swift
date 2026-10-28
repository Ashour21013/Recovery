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
            .background(
                LinearGradient(colors: [Color(light: 0xF9FBF8, dark: 0x102321),
                                        Color(light: 0xF4F7F4, dark: 0x152B28)],
                               startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: { Image(systemName: "xmark") }
                        .accessibilityLabel("Schließen")
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Wiederherstellen") { Task { await viewModel?.restore() } }
                        .font(.caption.weight(.bold))
                }
            }
        }
        .tint(AppColor.teal)
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
            VStack(spacing: 20) {
                header
                benefits(viewModel.benefits)
                products(viewModel)
                purchaseSection(viewModel)
                legalLinks
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 28)
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
        VStack(spacing: 0) {
            Image(systemName: "sparkles")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(Color(hex: 0xB0842F))
                .frame(width: 76, height: 76)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(LinearGradient(colors: [Color(hex: 0xFFF7D8), Color(hex: 0xEED38B)],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .shadow(color: Color(hex: 0xA97C28, opacity: 0.18), radius: 14, y: 12)
                )
                .rotationEffect(.degrees(-5))
                .padding(.top, 12)
                .padding(.bottom, 15)
                .accessibilityHidden(true)
            ProTag(text: String(localized: "RECOVERY PREMIUM"))
            Text("Mehr Unterstützung.\nMehr von deinem Fortschritt.")
                .font(.system(size: 27, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(AppColor.ink)
                .padding(.top, 13)
                .padding(.bottom, 8)
            Text("Alles, was dich auf deinem Weg nachhaltig stärkt.")
                .font(.footnote)
                .foregroundStyle(AppColor.muted)
                .multilineTextAlignment(.center)
        }
    }

    private func benefits(_ benefits: [PremiumBenefit]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(benefits) { benefit in
                HStack(spacing: 10) {
                    IconTile(systemImage: benefit.systemImage, size: 28)
                        .accessibilityHidden(true)
                    Text(benefit.title)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(AppColor.ink)
                    Spacer(minLength: 0)
                    Image(systemName: "checkmark")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(AppColor.teal)
                }
                .frame(minHeight: 36)
                .accessibilityElement(children: .combine)
            }
        }
        .padding(.horizontal, 4)
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
        VStack(spacing: 8) {
            Button {
                Task { await viewModel.purchaseSelected() }
            } label: {
                HStack {
                    if viewModel.isLoading { ProgressView().tint(.white) }
                    Text(purchaseTitle(viewModel))
                }
            }
            .buttonStyle(TealButtonStyle(fill: AppColor.deep))
            .shadow(color: AppColor.deep.opacity(0.18), radius: 12, y: 10)
            .disabled(viewModel.isLoading || viewModel.selectedProductID == nil)

            Text(viewModel.hasAnyFreeTrial
                 ? String(localized: "Jederzeit kündbar. Die Testphase wird automatisch in ein Abo umgewandelt, wenn du nicht kündigst.")
                 : String(localized: "Jederzeit kündbar."))
                .font(.caption2)
                .foregroundStyle(AppColor.muted)
                .multilineTextAlignment(.center)
        }
    }

    private func purchaseTitle(_ viewModel: PaywallViewModel) -> String {
        let selected = viewModel.displayProducts.first { $0.product.id == viewModel.selectedProductID }
        if let selected, selected.hasFreeTrial {
            return String(localized: "Kostenlos testen")
        }
        return String(localized: "Premium freischalten")
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
