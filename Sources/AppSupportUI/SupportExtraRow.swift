import SwiftUI

/// Optional extra row rendered after built-in support actions.
public struct SupportExtraRow: Identifiable {
    public let id: String
    public var title: String
    public var subtitle: String
    public var systemImage: String
    public var tint: Color
    public var action: @MainActor () -> Void

    public init(
        id: String,
        title: String,
        subtitle: String,
        systemImage: String,
        tint: Color = .accentColor,
        action: @escaping @MainActor () -> Void
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.tint = tint
        self.action = action
    }
}
