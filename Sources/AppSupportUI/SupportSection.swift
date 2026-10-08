public import AppSupportCore
public import SwiftUI

/// Convenience Section wrapper for hosts whose settings use a Form or List.
public struct SupportSection: View {
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
        if !SupportRows.availableRows(content: content, rows: rows).isEmpty {
            Section {
                SupportRows(
                    content: content,
                    rows: rows,
                    showBuildNumber: showBuildNumber,
                    versionPrefix: versionPrefix,
                    style: style,
                    onStart: onStart,
                    onResult: onResult
                )
            } header: {
                Text(content.copy.sectionTitle)
            }
        }
    }
}
