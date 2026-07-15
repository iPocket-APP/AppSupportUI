import SwiftUI

/// Settings-style tappable row with icon, title, subtitle, and chevron.
public struct SettingsActionRow: View {
    public var title: String
    public var subtitle: String
    public var systemImage: String
    public var tint: Color
    public var action: @MainActor () -> Void

    public init(
        title: String,
        subtitle: String,
        systemImage: String,
        tint: Color = .accentColor,
        action: @escaping @MainActor () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.tint = tint
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(tint)
                    .frame(minWidth: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 12)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .frame(minHeight: 44)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(title))
        .accessibilityHint(Text(subtitle))
    }
}

#Preview {
    Form {
        SettingsActionRow(
            title: "Contact Support",
            subtitle: "Get help with the app",
            systemImage: "envelope.fill",
            tint: .blue
        ) {}
    }
}
