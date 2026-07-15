import SwiftUI

/// Colors and SF Symbols for built-in support rows.
public struct SupportSectionStyle: Sendable {
    public var versionTint: Color
    public var rateTint: Color
    public var contactTint: Color
    public var privacyTint: Color
    public var termsTint: Color
    public var websiteTint: Color

    public var versionSystemImage: String
    public var rateSystemImage: String
    public var contactSystemImage: String
    public var privacySystemImage: String
    public var termsSystemImage: String
    public var websiteSystemImage: String

    public init(
        versionTint: Color = .accentColor,
        rateTint: Color = .orange,
        contactTint: Color = .accentColor,
        privacyTint: Color = .green,
        termsTint: Color = .blue,
        websiteTint: Color = .indigo,
        versionSystemImage: String = "info.circle.fill",
        rateSystemImage: String = "star.fill",
        contactSystemImage: String = "envelope.fill",
        privacySystemImage: String = "hand.raised.fill",
        termsSystemImage: String = "doc.text.fill",
        websiteSystemImage: String = "globe"
    ) {
        self.versionTint = versionTint
        self.rateTint = rateTint
        self.contactTint = contactTint
        self.privacyTint = privacyTint
        self.termsTint = termsTint
        self.websiteTint = websiteTint
        self.versionSystemImage = versionSystemImage
        self.rateSystemImage = rateSystemImage
        self.contactSystemImage = contactSystemImage
        self.privacySystemImage = privacySystemImage
        self.termsSystemImage = termsSystemImage
        self.websiteSystemImage = websiteSystemImage
    }
}
