public import SwiftUI
public import AppSupportCore

/// Shared colors and sizing for the built-in support rows.
public struct SupportSectionStyle: Sendable {
    public var versionTint: Color
    public var rateTint: Color
    public var contactTint: Color
    public var privacyTint: Color
    public var termsTint: Color
    public var websiteTint: Color

    public var iconWidth: CGFloat
    public var minimumRowHeight: CGFloat

    public init(
        versionTint: Color = .accentColor,
        rateTint: Color = .orange,
        contactTint: Color = .accentColor,
        privacyTint: Color = .green,
        termsTint: Color = .blue,
        websiteTint: Color = .indigo,
        iconWidth: CGFloat = 24,
        minimumRowHeight: CGFloat = SupportRowStyle.defaultMinimumHeight
    ) {
        self.versionTint = versionTint
        self.rateTint = rateTint
        self.contactTint = contactTint
        self.privacyTint = privacyTint
        self.termsTint = termsTint
        self.websiteTint = websiteTint
        self.iconWidth = iconWidth
        self.minimumRowHeight = minimumRowHeight
    }

    public func rowStyle(for row: SupportRowKind) -> SupportRowStyle {
        let tint: Color
        switch row {
        case .version: tint = versionTint
        case .rate: tint = rateTint
        case .contactEmail, .contactWebsite: tint = contactTint
        case .privacy: tint = privacyTint
        case .terms: tint = termsTint
        case .website: tint = websiteTint
        }
        return SupportRowStyle(tint: tint, iconWidth: iconWidth, minimumHeight: minimumRowHeight)
    }
}
