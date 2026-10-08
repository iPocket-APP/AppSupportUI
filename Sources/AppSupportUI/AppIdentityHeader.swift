public import AppSupportCore
public import SwiftUI

/// Compact identity header for an About page. The host supplies its real app icon.
public struct AppIdentityHeader<Icon: View>: View {
    private let identity: AppIdentity
    private let copy: SupportCopy
    private let showBuildNumber: Bool
    private let icon: Icon

    public init(
        identity: AppIdentity,
        copy: SupportCopy,
        showBuildNumber: Bool = false,
        @ViewBuilder icon: () -> Icon
    ) {
        self.identity = identity
        self.copy = copy
        self.showBuildNumber = showBuildNumber
        self.icon = icon()
    }

    public var body: some View {
        HStack(spacing: 16) {
            icon.accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(identity.name)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(identity.versionDisplay(
                    includeBuild: showBuildNumber,
                    unknownVersion: copy.unknownVersion
                ))
                .font(.footnote)
                .foregroundStyle(.secondary)
                .environment(\.layoutDirection, .leftToRight)
            }
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}
