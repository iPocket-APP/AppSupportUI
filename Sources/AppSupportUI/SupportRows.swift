public import AppSupportCore
public import SwiftUI

/// Built-in support rows without a Section wrapper, in the host's requested order.
public struct SupportRows: View {
    public static let defaultRows: [SupportRowKind] = [
        .version, .rate, .contactEmail, .contactWebsite, .privacy, .terms, .website,
    ]

    private let content: SupportContent
    private let rows: [SupportRowKind]
    private let showBuildNumber: Bool
    private let versionPrefix: String
    private let style: SupportSectionStyle
    private let onStart: @MainActor (SupportAction) -> Void
    private let onResult: @MainActor (SupportAction, SupportActionResult) -> Void

    public init(
        content: SupportContent,
        rows: [SupportRowKind] = SupportRows.defaultRows,
        showBuildNumber: Bool = false,
        versionPrefix: String = "v",
        style: SupportSectionStyle = SupportSectionStyle(),
        onStart: @escaping @MainActor (SupportAction) -> Void = { _ in },
        onResult: @escaping @MainActor (SupportAction, SupportActionResult) -> Void = { _, _ in }
    ) {
        self.content = content
        self.rows = rows
        self.showBuildNumber = showBuildNumber
        self.versionPrefix = versionPrefix
        self.style = style
        self.onStart = onStart
        self.onResult = onResult
    }

    public var body: some View {
        ForEach(Self.availableRows(content: content, rows: rows), id: \.self) { kind in
            switch kind {
            case .version:
                SupportVersionRow(
                    identity: content.identity,
                    copy: content.copy,
                    showBuildNumber: showBuildNumber,
                    prefix: versionPrefix,
                    tint: style.versionTint,
                    iconWidth: style.iconWidth
                )
                .frame(minHeight: style.minimumRowHeight)
            case .rate:
                if let url = content.links.reviewURL {
                    actionRow(kind: kind, copy: content.copy.rate, symbol: "star.fill", action: .openURL(url))
                }
            case .contactEmail:
                if let draft = content.makeMailDraft() {
                    actionRow(kind: kind, copy: content.copy.contact, symbol: "envelope.fill", action: .email(draft))
                }
            case .contactWebsite:
                if let url = SupportLinks.validatedWebURL(content.links.contactURL) {
                    actionRow(kind: kind, copy: content.copy.contactWebsite, symbol: "globe", action: .openURL(url))
                }
            case .privacy:
                if let url = SupportLinks.validatedWebURL(content.links.privacyURL) {
                    actionRow(kind: kind, copy: content.copy.privacy, symbol: "hand.raised.fill", action: .openURL(url))
                }
            case .terms:
                if let url = SupportLinks.validatedWebURL(content.links.termsURL) {
                    actionRow(kind: kind, copy: content.copy.terms, symbol: "doc.text.fill", action: .openURL(url))
                }
            case .website:
                if let url = SupportLinks.validatedWebURL(content.links.websiteURL) {
                    actionRow(kind: kind, copy: content.copy.website, symbol: "globe", action: .openURL(url))
                }
            }
        }
    }

    static func availableRows(content: SupportContent, rows: [SupportRowKind]) -> [SupportRowKind] {
        var seen = Set<SupportRowKind>()
        return rows.filter { kind in
            guard seen.insert(kind).inserted else { return false }
            switch kind {
            case .version: return true
            case .rate: return content.links.reviewURL != nil
            case .contactEmail: return content.links.normalizedEmail != nil
            case .contactWebsite: return SupportLinks.validatedWebURL(content.links.contactURL) != nil
            case .privacy: return SupportLinks.validatedWebURL(content.links.privacyURL) != nil
            case .terms: return SupportLinks.validatedWebURL(content.links.termsURL) != nil
            case .website: return SupportLinks.validatedWebURL(content.links.websiteURL) != nil
            }
        }
    }

    private func actionRow(
        kind: SupportRowKind,
        copy: SupportCopy.Row,
        symbol: String,
        action: SupportAction
    ) -> some View {
        let rowStyle = style.rowStyle(for: kind)
        return SupportActionButton(
            action: action,
            copy: content.copy,
            contactURL: SupportLinks.validatedWebURL(content.links.contactURL),
            minimumHeight: rowStyle.minimumHeight,
            onStart: onStart,
            onResult: onResult
        ) {
            SupportRowLabel(
                title: copy.title,
                subtitle: copy.subtitle,
                systemImage: symbol,
                tint: rowStyle.tint,
                iconWidth: rowStyle.iconWidth,
                accessory: .external
            )
        }
    }
}
