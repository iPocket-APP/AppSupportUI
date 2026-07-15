import SwiftUI

/// Drop-in Settings **Support** section for `Form` / `List`.
///
/// ```swift
/// Form {
///     SupportSettingsSection(
///         configuration: SupportSectionConfiguration(
///             supportEmail: "hi@example.com",
///             privacyPolicyURL: URL(string: "https://example.com/privacy")!,
///             appStoreID: "123456789"
///         )
///     )
/// }
/// ```
public struct SupportSettingsSection: View {
    @Environment(\.openURL) private var openURL

    private let configuration: SupportSectionConfiguration

    public init(configuration: SupportSectionConfiguration) {
        self.configuration = configuration
    }

    public var body: some View {
        Section {
            if configuration.showsVersion {
                versionRow
            }

            if configuration.shouldShowRateRow {
                SettingsActionRow(
                    title: resolvedRateTitle,
                    subtitle: resolvedRateSubtitle,
                    systemImage: configuration.style.rateSystemImage,
                    tint: configuration.style.rateTint,
                    action: openReview
                )
            }

            if configuration.shouldShowContactRow {
                SettingsActionRow(
                    title: resolvedContactTitle,
                    subtitle: resolvedContactSubtitle,
                    systemImage: configuration.style.contactSystemImage,
                    tint: configuration.style.contactTint,
                    action: openSupportEmail
                )
            }

            if let privacyURL = configuration.privacyPolicyURL {
                SettingsActionRow(
                    title: resolvedPrivacyTitle,
                    subtitle: resolvedPrivacySubtitle,
                    systemImage: configuration.style.privacySystemImage,
                    tint: configuration.style.privacyTint
                ) {
                    openURL(privacyURL)
                }
            }

            if let termsURL = configuration.termsOfUseURL {
                SettingsActionRow(
                    title: resolvedTermsTitle,
                    subtitle: resolvedTermsSubtitle,
                    systemImage: configuration.style.termsSystemImage,
                    tint: configuration.style.termsTint
                ) {
                    openURL(termsURL)
                }
            }

            if let websiteURL = configuration.websiteURL {
                SettingsActionRow(
                    title: resolvedWebsiteTitle,
                    subtitle: resolvedWebsiteSubtitle,
                    systemImage: configuration.style.websiteSystemImage,
                    tint: configuration.style.websiteTint
                ) {
                    openURL(websiteURL)
                }
            }

            ForEach(configuration.extraRows) { row in
                SettingsActionRow(
                    title: row.title,
                    subtitle: row.subtitle,
                    systemImage: row.systemImage,
                    tint: row.tint,
                    action: row.action
                )
            }
        } header: {
            Text(resolvedSectionTitle)
        }
    }

    // MARK: - Rows

    private var versionRow: some View {
        LabeledContent {
            Text(configuration.resolvedVersionDisplay)
        } label: {
            Label {
                Text(String(localized: "Version", bundle: .module))
            } icon: {
                Image(systemName: configuration.style.versionSystemImage)
                    .foregroundStyle(configuration.style.versionTint)
            }
        }
    }

    // MARK: - Actions

    private func openReview() {
        guard let reviewURL = configuration.reviewURL else { return }
        openURL(reviewURL)
    }

    private func openSupportEmail() {
        guard let url = configuration.mailtoURL() else { return }
        openURL(url)
    }

    // MARK: - Localized defaults

    private var resolvedSectionTitle: String {
        configuration.sectionTitle
            ?? String(localized: "Support", bundle: .module)
    }

    private var resolvedRateTitle: String {
        configuration.rateTitle
            ?? String(localized: "Rate \(configuration.resolvedAppName)", bundle: .module)
    }

    private var resolvedRateSubtitle: String {
        configuration.rateSubtitle
            ?? String(localized: "Share feedback on the App Store", bundle: .module)
    }

    private var resolvedContactTitle: String {
        configuration.contactTitle
            ?? String(localized: "Contact Support", bundle: .module)
    }

    private var resolvedContactSubtitle: String {
        configuration.contactSubtitle
            ?? String(localized: "Get help with the app", bundle: .module)
    }

    private var resolvedPrivacyTitle: String {
        configuration.privacyTitle
            ?? String(localized: "Privacy Policy", bundle: .module)
    }

    private var resolvedPrivacySubtitle: String {
        configuration.privacySubtitle
            ?? String(localized: "Read how we handle your data", bundle: .module)
    }

    private var resolvedTermsTitle: String {
        configuration.termsTitle
            ?? String(localized: "Terms of Use", bundle: .module)
    }

    private var resolvedTermsSubtitle: String {
        configuration.termsSubtitle
            ?? String(localized: "View the terms of use", bundle: .module)
    }

    private var resolvedWebsiteTitle: String {
        configuration.websiteTitle
            ?? String(localized: "Website", bundle: .module)
    }

    private var resolvedWebsiteSubtitle: String {
        configuration.websiteSubtitle
            ?? String(localized: "Visit our website", bundle: .module)
    }
}

#Preview("Minimal") {
    Form {
        SupportSettingsSection(
            configuration: SupportSectionConfiguration(
                appName: "Demo",
                supportEmail: "support@example.com",
                privacyPolicyURL: URL(string: "https://example.com/privacy")!,
                appStoreID: "123456789"
            )
        )
    }
}

#Preview("Themed") {
    Form {
        SupportSettingsSection(
            configuration: SupportSectionConfiguration(
                appName: "ImageSeal",
                supportEmail: "contact@example.com",
                privacyPolicyURL: URL(string: "https://example.com/privacy")!,
                termsOfUseURL: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!,
                contactSubtitle: "Get help with verification or exports",
                privacySubtitle: "Read how ImageSeal handles data",
                style: SupportSectionStyle(
                    versionTint: Color(red: 0.10, green: 0.55, blue: 0.72),
                    rateTint: Color(red: 0.86, green: 0.55, blue: 0.16),
                    contactTint: Color(red: 0.10, green: 0.55, blue: 0.72),
                    privacyTint: Color(red: 0.18, green: 0.66, blue: 0.50)
                )
            )
        )
    }
}
