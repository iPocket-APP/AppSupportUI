import Foundation

/// Complete, already resolved text. Hosts may supply any language without changing this package.
public struct SupportCopy: Sendable, Equatable {
    public struct Row: Sendable, Equatable {
        public var title: String
        public var subtitle: String?
        public init(title: String, subtitle: String? = nil) {
            self.title = title; self.subtitle = subtitle
        }
    }

    public struct Mail: Sendable, Equatable {
        public var subject: String
        public var prompt: String
        public var appLabel: String
        public var versionLabel: String
        public var buildLabel: String
        public var systemLabel: String
        public var deviceLabel: String
        public init(subject: String, prompt: String, appLabel: String, versionLabel: String,
                    buildLabel: String, systemLabel: String, deviceLabel: String) {
            self.subject = subject; self.prompt = prompt; self.appLabel = appLabel
            self.versionLabel = versionLabel; self.buildLabel = buildLabel
            self.systemLabel = systemLabel; self.deviceLabel = deviceLabel
        }
    }

    public struct Failure: Sendable, Equatable {
        public var title: String
        public var message: String
        public var copyEmail: String
        public var copyDiagnostics: String
        public var contactWebsite: String
        public var close: String
        public var copied: String
        public init(title: String, message: String, copyEmail: String, copyDiagnostics: String,
                    contactWebsite: String, close: String, copied: String) {
            self.title = title; self.message = message; self.copyEmail = copyEmail
            self.copyDiagnostics = copyDiagnostics; self.contactWebsite = contactWebsite; self.close = close
            self.copied = copied
        }
    }

    public var sectionTitle: String
    public var versionTitle: String
    public var unknownVersion: String
    public var rate: Row
    public var contact: Row
    public var contactWebsite: Row
    public var privacy: Row
    public var terms: Row
    public var website: Row
    public var mail: Mail
    public var failure: Failure

    /// All groups are required so a host's language is also used for hidden/error paths.
    public init(sectionTitle: String, versionTitle: String, unknownVersion: String,
                rate: Row, contact: Row, contactWebsite: Row, privacy: Row, terms: Row,
                website: Row, mail: Mail, failure: Failure) {
        self.sectionTitle = sectionTitle; self.versionTitle = versionTitle; self.unknownVersion = unknownVersion
        self.rate = rate; self.contact = contact; self.contactWebsite = contactWebsite
        self.privacy = privacy; self.terms = terms; self.website = website
        self.mail = mail; self.failure = failure
    }

    /// Package translations cover English and Simplified Chinese only.
    /// Other languages fall back as a whole to English; use the complete initializer for host translations.
    public static func packageDefaults(appName: String, language: String? = nil) -> Self {
        let selected = localizationIdentifier(for: language ?? Bundle.main.preferredLocalizations.first ?? "en")
        let bundle = Bundle.module.url(forResource: selected, withExtension: "lproj")
            .flatMap(Bundle.init(url:)) ?? Bundle.module
        func text(_ key: String) -> String { bundle.localizedString(forKey: key, value: nil, table: "Localizable") }
        func row(_ title: String, _ subtitle: String) -> Row { Row(title: text(title), subtitle: text(subtitle)) }
        return Self(
            sectionTitle: text("Support"), versionTitle: text("Version"), unknownVersion: text("Unknown"),
            rate: Row(title: String(format: text("Rate %@"), appName), subtitle: text("Share feedback on the App Store")),
            contact: row("Contact Support", "Get help with the app"),
            contactWebsite: row("Support Website", "Get help on our website"),
            privacy: row("Privacy Policy", "Read how we handle your data"),
            terms: row("Terms of Use", "View the terms of use"),
            website: row("Website", "Visit our website"),
            mail: Mail(subject: String(format: text("Support for %@"), appName),
                       prompt: text("Please describe the issue above this line."), appLabel: text("App"),
                       versionLabel: text("Version"), buildLabel: text("Build"), systemLabel: text("System"), deviceLabel: text("Device")),
            failure: Failure(title: text("Unable to Open"),
                             message: text("The system could not open this link. Please try again or use another support option."),
                             copyEmail: text("Copy Email Address"), copyDiagnostics: text("Copy Support Details"),
                             contactWebsite: text("Open Support Website"), close: text("Close"), copied: text("Copied"))
        )
    }

    static func localizationIdentifier(for language: String) -> String {
        let language = language.replacingOccurrences(of: "_", with: "-").lowercased()
        if language == "zh" || language == "zh-cn" || language == "zh-sg"
            || language == "zh-hans" || language.hasPrefix("zh-hans-") { return "zh-Hans" }
        return "en"
    }
}
