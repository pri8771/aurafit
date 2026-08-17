import SwiftUI
import StoreKit

/// The Pro upsell / IAP screen. Lists subscriptions and template unlocks, handles purchase &
/// restore, and tailors its headline to the `PaywallContext` that triggered it.
struct PaywallView: View {
    let context: PaywallContext

    @Environment(AppEnvironment.self) private var environment
    @Environment(AppRouter.self) private var router
    @Environment(\.dismiss) private var dismiss

    @State private var selectedProductID: String?
    @State private var isPurchasing = false
    @State private var errorMessage: String?
    @State private var restoreMessage: String?

    private var entitlements: EntitlementManager { environment.entitlements }

    /// Whether any non-consumable template is owned. Only meaningful once Pro has been ruled
    /// out, since `isTemplateUnlocked` reports true for everything while Pro is active.
    private var hasUnlockedTemplates: Bool {
        ProductCatalog.templateIDs.contains { entitlements.isTemplateUnlocked($0) }
    }

    private var subscriptions: [Product] {
        entitlements.products.filter { ProductCatalog.isProSubscription($0.id) }
    }
    private var templates: [Product] {
        entitlements.products.filter { ProductCatalog.isTemplate($0.id) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AFSpacing.lg) {
                    header
                    benefits
                    productsSection
                    purchaseButton
                    templatesSection
                    legal
                }
                .padding(AFSpacing.md)
            }
            .scrollIndicators(.hidden)
            .afScreenBackground()
            .navigationTitle("AuraFit Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(AFColors.textSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Restore") { Task { await restore() } }
                        .foregroundStyle(AFColors.accent)
                }
            }
            .task {
                if entitlements.products.isEmpty { await entitlements.loadProducts() }
                selectedProductID = subscriptions.first?.id ?? ProductCatalog.proYearly
            }
            .alert("Purchase Error", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
            .alert("Restore Purchases", isPresented: Binding(
                get: { restoreMessage != nil },
                set: { if !$0 { restoreMessage = nil } }
            )) {
                Button("OK") { restoreMessage = nil }
            } message: {
                Text(restoreMessage ?? "")
            }
            .onChange(of: entitlements.isPro) { _, isPro in
                if isPro { dismiss() }
            }
        }
        .accessibilityIdentifier("aurafit.paywall.root.container")
    }

    // MARK: - Sections

    private var header: some View {
        VStack(spacing: AFSpacing.sm) {
            ZStack {
                Circle().fill(AFColors.brandGradient).frame(width: 90, height: 90).blur(radius: 22).opacity(0.6)
                Image(systemName: "sparkles")
                    .font(.system(size: 48))
                    .foregroundStyle(AFColors.brandGradient)
            }
            Text(context.headline)
                .font(AFTypography.title(.bold))
                .foregroundStyle(AFColors.textPrimary)
                .multilineTextAlignment(.center)
            Text(context.subheadline)
                .font(AFTypography.subheadline())
                .foregroundStyle(AFColors.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var benefits: some View {
        AFGlassCard {
            VStack(alignment: .leading, spacing: AFSpacing.sm) {
                BenefitRow(icon: "infinity", title: "Unlimited scans", subtitle: "No daily limits")
                BenefitRow(icon: "drop.triangle", title: "No watermark", subtitle: "Clean, pro exports")
                BenefitRow(icon: "play.rectangle.fill", title: "Reveal clips", subtitle: "5-second score videos")
                BenefitRow(icon: "paintpalette.fill", title: "All templates", subtitle: "Every scorecard style")
            }
        }
    }

    @ViewBuilder
    private var productsSection: some View {
        if subscriptions.isEmpty {
            unavailableProducts
        } else {
            VStack(spacing: AFSpacing.sm) {
                ForEach(subscriptions) { product in
                    SubscriptionOption(
                        product: product,
                        isSelected: selectedProductID == product.id,
                        isBestValue: product.id == ProductCatalog.proYearly
                    ) {
                        HapticsManager.shared.selection()
                        selectedProductID = product.id
                    }
                }
            }
        }
    }

    private var unavailableProducts: some View {
        AFGlassCard {
            VStack(spacing: AFSpacing.xs) {
                if entitlements.loadState == .loading {
                    ProgressView().tint(AFColors.accent)
                    Text("Loading plans…").font(AFTypography.subheadline()).foregroundStyle(AFColors.textSecondary)
                } else {
                    Image(systemName: "wifi.exclamationmark").font(.title).foregroundStyle(AFColors.warning)
                    Text("Plans unavailable")
                        .font(AFTypography.headline()).foregroundStyle(AFColors.textPrimary)
                    Text("Couldn't reach the App Store. Check your connection and try again.")
                        .font(AFTypography.caption()).foregroundStyle(AFColors.textSecondary)
                        .multilineTextAlignment(.center)
                    Button("Retry") { Task { await entitlements.loadProducts() } }
                        .font(AFTypography.subheadline(.semibold))
                        .foregroundStyle(AFColors.accent)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private var purchaseButton: some View {
        if !subscriptions.isEmpty {
            AFPrimaryButton(
                title: purchaseTitle,
                systemImage: "lock.open.fill",
                isLoading: isPurchasing
            ) {
                Task { await purchaseSelected() }
            }
        }
    }

    private var purchaseTitle: String {
        guard let id = selectedProductID, let product = entitlements.product(for: id) else {
            return "Continue"
        }
        return "Subscribe • \(product.displayPrice)"
    }

    @ViewBuilder
    private var templatesSection: some View {
        if !templates.isEmpty {
            VStack(alignment: .leading, spacing: AFSpacing.sm) {
                AFSectionHeader(title: "Template Packs")
                Text("Prefer a one-time unlock? Buy individual scorecard styles.")
                    .font(AFTypography.caption())
                    .foregroundStyle(AFColors.textSecondary)
                ForEach(templates) { product in
                    TemplateOption(
                        product: product,
                        isUnlocked: entitlements.isTemplateUnlocked(product.id),
                        isPurchasing: isPurchasing
                    ) {
                        Task { await purchase(product) }
                    }
                }
            }
        }
    }

    private var legal: some View {
        VStack(spacing: AFSpacing.xs) {
            Text("Payment is charged to your Apple ID. Subscriptions auto-renew unless cancelled at least 24 hours before the end of the period. Manage in Settings.")
                .font(AFTypography.caption())
                .foregroundStyle(AFColors.textTertiary)
                .multilineTextAlignment(.center)
            HStack(spacing: AFSpacing.md) {
                Link("Terms", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                // A subscription paywall must link this app's privacy policy, not Apple's.
                NavigationLink("Privacy") { PrivacyPolicyView() }
            }
            .font(AFTypography.caption(.semibold))
            .foregroundStyle(AFColors.accent)
        }
        .padding(.top, AFSpacing.sm)
    }

    // MARK: - Actions

    private func purchaseSelected() async {
        guard let id = selectedProductID, let product = entitlements.product(for: id) else { return }
        await purchase(product)
    }

    private func purchase(_ product: Product) async {
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            let outcome = try await entitlements.purchase(product)
            switch outcome {
            case .success:
                HapticsManager.shared.notify(.success)
                // Dismissal handled by onChange(isPro) for subscriptions; close for templates too.
                if ProductCatalog.isTemplate(product.id) { dismiss() }
            case .pending:
                errorMessage = "Your purchase is pending approval."
            case .cancelled:
                break
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// `AppStore.sync()` restores every owned product, not just subscriptions, so a
    /// template-only owner must be told the restore worked rather than that nothing was found.
    private func restore() async {
        let synced = await entitlements.restore()
        if entitlements.isPro {
            HapticsManager.shared.notify(.success)
            dismiss()
        } else if !synced {
            errorMessage = "Couldn't connect to the App Store. Check your connection and try again."
        } else if hasUnlockedTemplates {
            HapticsManager.shared.notify(.success)
            restoreMessage = "Your template packs have been restored."
        } else {
            errorMessage = "No purchases found to restore."
        }
    }
}

// MARK: - Subviews

private struct BenefitRow: View {
    let icon: String, title: String, subtitle: String
    var body: some View {
        HStack(spacing: AFSpacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(AFColors.accent)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(AFTypography.subheadline(.semibold)).foregroundStyle(AFColors.textPrimary)
                Text(subtitle).font(AFTypography.caption()).foregroundStyle(AFColors.textSecondary)
            }
            Spacer()
            Image(systemName: "checkmark.circle.fill").foregroundStyle(AFColors.success)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct SubscriptionOption: View {
    let product: Product
    let isSelected: Bool
    let isBestValue: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AFSpacing.md) {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .foregroundStyle(isSelected ? AFColors.accent : AFColors.textTertiary)
                    .font(.title3)
                VStack(alignment: .leading, spacing: 2) {
                    Text(product.displayName)
                        .font(AFTypography.headline())
                        .foregroundStyle(AFColors.textPrimary)
                    Text(product.description)
                        .font(AFTypography.caption())
                        .foregroundStyle(AFColors.textSecondary)
                        .lineLimit(2)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(product.displayPrice)
                        .font(AFTypography.headline(.bold))
                        .foregroundStyle(AFColors.textPrimary)
                    if isBestValue {
                        Text("BEST VALUE")
                            .font(AFTypography.caption(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(AFColors.brandGradient, in: Capsule())
                    }
                }
            }
            .padding(AFSpacing.md)
            .background(AFColors.surface, in: RoundedRectangle(cornerRadius: AFRadius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AFRadius.md, style: .continuous)
                    .strokeBorder(isSelected ? AFColors.accent : AFColors.stroke, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(AFPressStyle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

private struct TemplateOption: View {
    let product: Product
    let isUnlocked: Bool
    let isPurchasing: Bool
    let action: () -> Void

    var body: some View {
        HStack(spacing: AFSpacing.md) {
            Image(systemName: "paintpalette.fill")
                .foregroundStyle(AFColors.accentSecondary)
            VStack(alignment: .leading, spacing: 1) {
                Text(product.displayName).font(AFTypography.subheadline(.semibold)).foregroundStyle(AFColors.textPrimary)
                Text(product.description).font(AFTypography.caption()).foregroundStyle(AFColors.textSecondary).lineLimit(1)
            }
            Spacer()
            if isUnlocked {
                Label("Unlocked", systemImage: "checkmark.seal.fill")
                    .font(AFTypography.caption(.semibold))
                    .foregroundStyle(AFColors.success)
            } else {
                Button(action: action) {
                    Text(product.displayPrice)
                        .font(AFTypography.subheadline(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, AFSpacing.md)
                        .padding(.vertical, AFSpacing.xs)
                        .background(AFColors.accent, in: Capsule())
                }
                .disabled(isPurchasing)
            }
        }
        .padding(AFSpacing.sm)
        .background(AFColors.surface, in: RoundedRectangle(cornerRadius: AFRadius.md, style: .continuous))
    }
}

#Preview {
    PaywallView(context: .dailyLimitReached)
        .environment(AppEnvironment.preview())
        .environment(AppRouter())
}
