import Foundation

/// Optional endpoints. Invalid or absent endpoints do not produce built-in actions.
public struct SupportLinks: Sendable, Equatable {
    public var email: String?
    public var contactURL: URL?
    public var privacyURL: URL?
    public var termsURL: URL?
    public var websiteURL: URL?
    public var appStoreID: String?

    public init(
        email: String? = nil, contactURL: URL? = nil, privacyURL: URL? = nil,
        termsURL: URL? = nil, websiteURL: URL? = nil, appStoreID: String? = nil
    ) {
        self.email = email
        self.contactURL = contactURL
        self.privacyURL = privacyURL
        self.termsURL = termsURL
        self.websiteURL = websiteURL
        self.appStoreID = appStoreID
    }

    public var normalizedEmail: String? { email.flatMap(Self.normalizeEmail) }

    public var reviewURL: URL? {
        guard var candidate = appStoreID?.trimmingCharacters(in: .whitespacesAndNewlines) else { return nil }
        if candidate.lowercased().hasPrefix("id") { candidate.removeFirst(2) }
        guard !candidate.isEmpty, candidate.unicodeScalars.allSatisfy({ (48...57).contains($0.value) }) else { return nil }
        return URL(string: "https://apps.apple.com/app/id\(candidate)?action=write-review")
    }

    public static func validatedWebURL(_ url: URL?) -> URL? {
        guard let url, let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let scheme = components.scheme?.lowercased(), ["https", "http"].contains(scheme),
              let host = components.host, !host.isEmpty else { return nil }
        return url
    }

    public static func normalizeEmail(_ email: String) -> String? {
        let candidate = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !candidate.isEmpty, !candidate.unicodeScalars.contains(where: {
            CharacterSet.whitespacesAndNewlines.contains($0) || CharacterSet.controlCharacters.contains($0)
        }) else { return nil }
        let parts = candidate.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == 2, !parts[0].isEmpty, !parts[1].isEmpty else { return nil }
        return candidate
    }
}
