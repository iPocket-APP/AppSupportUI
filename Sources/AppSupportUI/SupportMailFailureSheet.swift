import AppSupportCore
import SwiftUI

struct SupportMailFailureSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var copiedEmail = false
    @State private var copiedDiagnostics = false

    let draft: SupportMailDraft
    let copy: SupportCopy
    let contactURL: URL?
    let onStart: @MainActor (SupportAction) -> Void
    let onResult: @MainActor (SupportAction, SupportActionResult) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(copy.failure.message)
                    Text(draft.recipient)
                        .textSelection(.enabled)
                        .environment(\.layoutDirection, .leftToRight)
                }

                Section {
                    Button {
                        SupportClipboard.copy(draft.recipient)
                        copiedEmail = true
                    } label: {
                        Label(copy.failure.copyEmail, systemImage: copiedEmail ? "checkmark" : "doc.on.doc")
                    }
                    .accessibilityLabel(copy.failure.copyEmail)
                    .accessibilityValue(copiedEmail ? copy.failure.copied : "")

                    Button {
                        SupportClipboard.copy(draft.body)
                        copiedDiagnostics = true
                    } label: {
                        Label(copy.failure.copyDiagnostics, systemImage: copiedDiagnostics ? "checkmark" : "doc.on.doc")
                    }
                    .accessibilityLabel(copy.failure.copyDiagnostics)
                    .accessibilityValue(copiedDiagnostics ? copy.failure.copied : "")

                    if let contactURL {
                        SupportActionButton(
                            action: .openURL(contactURL),
                            copy: copy,
                            onStart: onStart,
                            onResult: onResult
                        ) {
                            SupportRowLabel(
                                title: copy.failure.contactWebsite,
                                systemImage: "globe",
                                accessory: .external
                            )
                        }
                    }
                }

                Section {
                    Text(draft.body)
                        .font(.footnote)
                        .textSelection(.enabled)
                }
            }
            .formStyle(.grouped)
            .navigationTitle(copy.failure.title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(copy.failure.close) { dismiss() }
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 360, idealWidth: 440, minHeight: 400, idealHeight: 520)
        #endif
    }
}
