import Foundation

/// Resolved content can be used from settings, an About page, or an error recovery flow.
public struct SupportContent: Sendable, Equatable {
    public var identity: AppIdentity
    public var links: SupportLinks
    public var copy: SupportCopy

    public init(identity: AppIdentity, links: SupportLinks, copy: SupportCopy) {
        self.identity = identity
        self.links = links
        self.copy = copy
    }

    public func makeMailDraft(diagnostics: SupportDiagnostics = .current()) -> SupportMailDraft? {
        guard let email = links.normalizedEmail else { return nil }
        let labels = copy.mail
        var lines = ["", "", labels.prompt, "---", "\(labels.appLabel): \(identity.name)",
                     "\(labels.versionLabel): \(identity.version.isEmpty ? copy.unknownVersion : identity.version)"]
        if let build = identity.build { lines.append("\(labels.buildLabel): \(build)") }
        lines += ["\(labels.systemLabel): \(diagnostics.systemName) \(diagnostics.systemVersion)",
                  "\(labels.deviceLabel): \(diagnostics.deviceModel)"]
        lines += diagnostics.additionalFields.map { "\($0.label): \($0.value)" }
        return SupportMailDraft(recipient: email, subject: labels.subject, body: lines.joined(separator: "\n"))
    }
}
