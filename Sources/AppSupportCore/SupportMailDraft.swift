import Foundation

/// Plain text remains available even if the system cannot open a mail client.
public struct SupportMailDraft: Sendable, Equatable {
    public var recipient: String
    public var subject: String
    public var body: String

    public init(recipient: String, subject: String, body: String) {
        self.recipient = recipient.trimmingCharacters(in: .whitespacesAndNewlines)
        self.subject = subject
        self.body = body
    }

    public var mailtoURL: URL? {
        guard let recipient = SupportLinks.normalizeEmail(recipient) else { return nil }
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = recipient
        components.queryItems = [URLQueryItem(name: "subject", value: subject), URLQueryItem(name: "body", value: body)]
        return components.url
    }
}
