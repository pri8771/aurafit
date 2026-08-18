import SwiftUI

/// AuraFit's own privacy policy, rendered in-app so the Settings link resolves to a policy for
/// *this* app rather than Apple's corporate one (App Review Guideline 5.1.1(i)).
///
/// The text mirrors `docs/PRIVACY_POLICY.md`; the two are the same policy in two places and
/// must be edited together. A hosted copy at a public URL is still required for App Store
/// Connect metadata (`AURA-MKT-004`) and is not a substitute for this screen.
struct PrivacyPolicyView: View {

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AFSpacing.lg) {
                summary
                ForEach(Self.sections) { section in
                    PolicySectionView(section: section)
                }
                Text("Effective \(Self.effectiveDate). AuraFit, bundle ID com.pchordia.aurafit.")
                    .font(AFTypography.caption())
                    .foregroundStyle(AFColors.textTertiary)
            }
            .padding(AFSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
        .afScreenBackground()
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Sections

    private var summary: some View {
        AFGlassCard {
            HStack(alignment: .top, spacing: AFSpacing.md) {
                Image(systemName: "lock.shield.fill")
                    .font(.title2)
                    .foregroundStyle(AFColors.success)
                VStack(alignment: .leading, spacing: AFSpacing.xs) {
                    Text("The short version")
                        .font(AFTypography.headline())
                        .foregroundStyle(AFColors.textPrimary)
                    Text("AuraFit does not collect your data. There is no account, no server, no analytics, and nothing to buy — every feature is free. Every photo you scan is analyzed on your iPhone and stored only on your iPhone. The app has no networking code of its own, so there is nowhere for your photos or scores to go.")
                        .font(AFTypography.subheadline())
                        .foregroundStyle(AFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: - Content

    static let effectiveDate = "29 July 2026, updated 18 August 2026"

    struct PolicySection: Identifiable {
        let title: String
        var body: [String] = []
        var bullets: [String] = []
        var id: String { title }
    }

    static let sections: [PolicySection] = [
        PolicySection(
            title: "What the app stores, and where",
            body: ["Everything below stays in AuraFit's private app sandbox on your device. Deleting the app deletes all of it."],
            bullets: [
                "Photos you capture or import for a scan, saved as JPEG files in the app's Documents directory.",
                "Scores, tips, style match, and color palette, saved in a local database.",
                "Scorecard images and reveal clips you generate, which leave the device only if you share or save them yourself.",
                "Your preferences: haptics, sound effects, and auto-save."
            ]
        ),
        PolicySection(
            title: "How photos are analyzed",
            body: [
                "Analysis runs entirely on your device. Apple's Vision framework estimates body pose and person segmentation, Core Image measures image and color signals, and AuraFit uses a deterministic color-based heuristic for the closest style match. No learned outfit-classifier model is bundled in this release. Nothing is uploaded for processing.",
                "Scores are subjective guidance about an outfit and a photograph. They are not a measurement of any person, and the app does not identify, recognize, or profile anyone."
            ]
        ),
        PolicySection(
            title: "What we do not do",
            bullets: [
                "We do not collect, transmit, sell, or share your personal data.",
                "We do not use analytics, advertising, attribution, or crash-reporting SDKs.",
                "We do not track you across apps or websites.",
                "We do not create accounts, and we never ask for your name, email, or phone number.",
                "We do not sell anything inside the app. There is nothing to buy, so the app holds no payment information of any kind.",
                "We include no third-party libraries or code."
            ]
        ),
        PolicySection(
            title: "Permissions the app asks for",
            bullets: [
                "Camera, only to capture the photo you are about to scan. The camera is not used in the background.",
                "Import uses Apple's system photo picker. AuraFit receives only the image you select and does not request broad Photo Library read access.",
                "Photo Library add access, only when you tap Save or turn on auto-save, so scorecards and reveal clips can be written to your library."
            ]
        ),
        PolicySection(
            title: "Sharing is always your choice",
            body: ["Scorecards and reveal clips are shared only when you tap Share or Save and pick a destination in the iOS share sheet. Whatever you send then travels under the privacy policy of the app or service you sent it to, not this one."]
        ),
        PolicySection(
            title: "Links that leave the app",
            body: ["Terms of Use opens Apple's standard licence page in your system browser. Opening a link sends no AuraFit data along with it. It is the only outbound destination in the app."]
        ),
        PolicySection(
            title: "Children",
            body: ["AuraFit is not directed at children and collects no data from anyone, including children."]
        ),
        PolicySection(
            title: "Your rights",
            body: ["Because no data ever reaches us, there is nothing for us to look up, export, correct, or delete on your behalf. You hold the only copy. Settings, then Delete All Fits, removes every saved scan and its images immediately, and deleting the app removes everything else."]
        ),
        PolicySection(
            title: "Changes to this policy",
            body: ["If the app's data practices ever change, this policy will be updated before the change ships and the effective date will move."]
        ),
        PolicySection(
            title: "Contact",
            body: ["Questions about this policy can be sent to the developer through the app's App Store listing."]
        )
    ]
}

// MARK: - Subviews

private struct PolicySectionView: View {
    let section: PrivacyPolicyView.PolicySection

    var body: some View {
        VStack(alignment: .leading, spacing: AFSpacing.sm) {
            Text(section.title)
                .font(AFTypography.title3(.bold))
                .foregroundStyle(AFColors.textPrimary)
            ForEach(Array(section.body.enumerated()), id: \.offset) { _, paragraph in
                Text(paragraph)
                    .font(AFTypography.subheadline())
                    .foregroundStyle(AFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            ForEach(Array(section.bullets.enumerated()), id: \.offset) { _, bullet in
                HStack(alignment: .top, spacing: AFSpacing.sm) {
                    Circle()
                        .fill(AFColors.accent)
                        .frame(width: 5, height: 5)
                        .padding(.top, 7)
                    Text(bullet)
                        .font(AFTypography.subheadline())
                        .foregroundStyle(AFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
}
