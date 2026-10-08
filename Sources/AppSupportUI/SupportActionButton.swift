public import AppSupportCore
public import SwiftUI

/// Opens a support action through the host's OpenURLAction and presents a recoverable failure.
public struct SupportActionButton<Label: View>: View {
    @Environment(\.openURL) private var openURL
    @State private var isOpening = false
    @State private var mailFailure: SupportMailFailure?
    @State private var showsURLFailure = false

    private let action: SupportAction
    private let copy: SupportCopy
    private let contactURL: URL?
    private let minimumHeight: CGFloat
    private let onStart: @MainActor (SupportAction) -> Void
    private let onResult: @MainActor (SupportAction, SupportActionResult) -> Void
    private let label: Label

    public init(
        action: SupportAction,
        copy: SupportCopy,
        contactURL: URL? = nil,
        minimumHeight: CGFloat = SupportRowStyle.defaultMinimumHeight,
        onStart: @escaping @MainActor (SupportAction) -> Void = { _ in },
        onResult: @escaping @MainActor (SupportAction, SupportActionResult) -> Void = { _, _ in },
        @ViewBuilder label: () -> Label
    ) {
        self.action = action
        self.copy = copy
        self.contactURL = contactURL
        self.minimumHeight = minimumHeight
        self.onStart = onStart
        self.onResult = onResult
        self.label = label()
    }

    public var body: some View {
        Button(action: performAction) {
            label
                .frame(minHeight: minimumHeight)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isOpening)
        .sheet(item: $mailFailure) { failure in
            SupportMailFailureSheet(
                draft: failure.draft,
                copy: copy,
                contactURL: contactURL,
                onStart: onStart,
                onResult: onResult
            )
        }
        .alert(copy.failure.title, isPresented: $showsURLFailure) {
            Button(copy.failure.close, role: .cancel) {}
        } message: {
            Text(copy.failure.message)
        }
    }

    private func performAction() {
        guard !isOpening else { return }
        isOpening = true
        onStart(action)
        SupportActionExecutor.execute(action, openURL: openURL) { result in
            isOpening = false
            switch result {
            case .accepted:
                break
            case .rejected, .invalid:
                switch action {
                case .email(let draft):
                    mailFailure = SupportMailFailure(draft: draft)
                case .openURL:
                    showsURLFailure = true
                }
            }
            onResult(action, result)
        }
    }
}
