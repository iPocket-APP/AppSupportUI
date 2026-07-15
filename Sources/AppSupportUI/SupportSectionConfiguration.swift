import Foundation
import SwiftUI

/// Host-app configuration for ``SupportSettingsSection``.
public struct SupportSectionConfiguration {
    // MARK: Identity

    /// Display name used in Rate title / mail subject. `nil` → bundle display name.
    public var appName: String?
    /// Override for the version value. `nil` → ``AppVersionInfo/versionDisplay``.
    public var versionDisplay: String?
    public var showBuildNumber: Bool
    public var versionPrefix: String

    // MARK: Links (nil = hide corresponding row when applicable)

    public var supportEmail: String?
    public var privacyPolicyURL: URL?
    public var termsOfUseURL: URL?
    public var websiteURL: URL?
    /// Numeric App Store id (no `"id"` prefix). Used for write-review deep link.
    public var appStoreID: String?

    // MARK: Row visibility

    public var showsVersion: Bool
    public var showsRate: Bool

    // MARK: Copy overrides (nil = package defaults)

    public var sectionTitle: String?
    public var rateTitle: String?
    public var rateSubtitle: String?
    public var contactTitle: String?
    public var contactSubtitle: String?
    public var privacyTitle: String?
    public var privacySubtitle: String?
    public var termsTitle: String?
    public var termsSubtitle: String?
    public var websiteTitle: String?
    public var websiteSubtitle: String?

    // MARK: Mail

    public var mailSubject: String?
    public var mailBodyPrompt: String?

    // MARK: Style & extras

    public var style: SupportSectionStyle
    public var extraRows: [SupportExtraRow]

    public init(
        appName: String? = nil,
        versionDisplay: String? = nil,
        showBuildNumber: Bool = false,
        versionPrefix: String = "v",
        supportEmail: String? = nil,
        privacyPolicyURL: URL? = nil,
        termsOfUseURL: URL? = nil,
        websiteURL: URL? = nil,
        appStoreID: String? = nil,
        showsVersion: Bool = true,
        showsRate: Bool = true,
        sectionTitle: String? = nil,
        rateTitle: String? = nil,
        rateSubtitle: String? = nil,
        contactTitle: String? = nil,
        contactSubtitle: String? = nil,
        privacyTitle: String? = nil,
        privacySubtitle: String? = nil,
        termsTitle: String? = nil,
        termsSubtitle: String? = nil,
        websiteTitle: String? = nil,
        websiteSubtitle: String? = nil,
        mailSubject: String? = nil,
        mailBodyPrompt: String? = nil,
        style: SupportSectionStyle = SupportSectionStyle(),
        extraRows: [SupportExtraRow] = []
    ) {
        self.appName = appName
        self.versionDisplay = versionDisplay
        self.showBuildNumber = showBuildNumber
        self.versionPrefix = versionPrefix
        self.supportEmail = supportEmail
        self.privacyPolicyURL = privacyPolicyURL
        self.termsOfUseURL = termsOfUseURL
        self.websiteURL = websiteURL
        self.appStoreID = appStoreID
        self.showsVersion = showsVersion
        self.showsRate = showsRate
        self.sectionTitle = sectionTitle
        self.rateTitle = rateTitle
        self.rateSubtitle = rateSubtitle
        self.contactTitle = contactTitle
        self.contactSubtitle = contactSubtitle
        self.privacyTitle = privacyTitle
        self.privacySubtitle = privacySubtitle
        self.termsTitle = termsTitle
        self.termsSubtitle = termsSubtitle
        self.websiteTitle = websiteTitle
        self.websiteSubtitle = websiteSubtitle
        self.mailSubject = mailSubject
        self.mailBodyPrompt = mailBodyPrompt
        self.style = style
        self.extraRows = extraRows
    }

    // MARK: Resolved values

    public var resolvedAppName: String {
        appName ?? AppVersionInfo.appDisplayName()
    }

    public var resolvedVersionDisplay: String {
        versionDisplay
            ?? AppVersionInfo.versionDisplay(
                prefix: versionPrefix,
                includeBuildNumber: showBuildNumber
            )
    }

    /// Normalized numeric App Store id, or `nil` if invalid.
    public var resolvedAppStoreID: String? {
        guard let appStoreID else { return nil }
        var candidate = appStoreID.trimmingCharacters(in: .whitespacesAndNewlines)
        if candidate.lowercased().hasPrefix("id") {
            candidate.removeFirst(2)
        }
        guard !candidate.isEmpty,
              candidate.unicodeScalars.allSatisfy({ (48...57).contains($0.value) })
        else {
            return nil
        }
        return candidate
    }

    /// `https://apps.apple.com/app/id{id}?action=write-review`
    public var reviewURL: URL? {
        guard let id = resolvedAppStoreID else { return nil }
        return URL(string: "https://apps.apple.com/app/id\(id)?action=write-review")
    }

    public var shouldShowRateRow: Bool {
        showsRate && reviewURL != nil
    }

    /// Whether the contact row has an email address that can produce a mail draft.
    public var shouldShowContactRow: Bool {
        guard let supportEmail else { return false }
        return SupportMailComposer.normalizedEmail(supportEmail) != nil
    }

    public func resolvedMailSubject() -> String {
        mailSubject ?? SupportMailComposer.defaultSubject(appName: resolvedAppName)
    }

    public func mailtoURL() -> URL? {
        guard let supportEmail else { return nil }
        return SupportMailComposer.mailtoURL(
            email: supportEmail,
            subject: resolvedMailSubject(),
            bodyPrompt: mailBodyPrompt,
            diagnostics: .current(
                appName: resolvedAppName,
                appVersion: resolvedVersionDisplay
            )
        )
    }
}
