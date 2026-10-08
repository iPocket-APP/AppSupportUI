public import AppSupportCore
public import SwiftUI

/// A noninteractive version row that follows the same icon alignment as support actions.
public struct SupportVersionRow: View {
    private let identity: AppIdentity
    private let copy: SupportCopy
    private let showBuildNumber: Bool
    private let prefix: String
    private let tint: Color
    private let iconWidth: CGFloat

    public init(
        identity: AppIdentity,
        copy: SupportCopy,
        showBuildNumber: Bool = false,
        prefix: String = "v",
        tint: Color = .accentColor,
        iconWidth: CGFloat = 24
    ) {
        self.identity = identity
        self.copy = copy
        self.showBuildNumber = showBuildNumber
        self.prefix = prefix
        self.tint = tint
        self.iconWidth = iconWidth
    }

    public var body: some View {
        LabeledContent {
            Text(identity.versionDisplay(
                includeBuild: showBuildNumber,
                prefix: prefix,
                unknownVersion: copy.unknownVersion
            ))
            .fixedSize(horizontal: false, vertical: true)
            .environment(\.layoutDirection, .leftToRight)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "info.circle.fill")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(tint)
                    .frame(minWidth: iconWidth)
                    .accessibilityHidden(true)
                Text(copy.versionTitle)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(minHeight: SupportRowStyle.defaultMinimumHeight)
    }
}
