public import SwiftUI

/// A settings label that can be placed inside a host-owned Button or NavigationLink.
public struct SupportRowLabel: View {
    private let title: String
    private let subtitle: String?
    private let systemImage: String
    private let tint: Color
    private let iconWidth: CGFloat
    private let accessory: SupportRowAccessory

    public init(
        title: String,
        subtitle: String? = nil,
        systemImage: String,
        tint: Color = .accentColor,
        iconWidth: CGFloat = 24,
        accessory: SupportRowAccessory = .forward
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.tint = tint
        self.iconWidth = iconWidth
        self.accessory = accessory
    }

    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.body.weight(.semibold))
                .foregroundStyle(tint)
                .frame(minWidth: iconWidth)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundStyle(.primary)
                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 12)

            switch accessory {
            case .forward:
                accessoryImage("chevron.forward")
            case .external:
                accessoryImage("arrow.up.forward")
            case .none:
                EmptyView()
            }
        }
        .frame(minHeight: SupportRowStyle.defaultMinimumHeight)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }

    private func accessoryImage(_ name: String) -> some View {
        Image(systemName: name)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.tertiary)
            .accessibilityHidden(true)
    }
}
