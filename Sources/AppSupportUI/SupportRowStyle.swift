public import SwiftUI

/// Sizing and color for a row label shared with host-owned buttons or navigation links.
public struct SupportRowStyle: Sendable {
    public var tint: Color
    public var iconWidth: CGFloat
    public var minimumHeight: CGFloat

    public static var defaultMinimumHeight: CGFloat {
        #if os(macOS)
        32
        #else
        44
        #endif
    }

    public init(
        tint: Color = .accentColor,
        iconWidth: CGFloat = 24,
        minimumHeight: CGFloat = SupportRowStyle.defaultMinimumHeight
    ) {
        self.tint = tint
        self.iconWidth = iconWidth
        self.minimumHeight = minimumHeight
    }
}
