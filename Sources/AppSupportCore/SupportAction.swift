import Foundation

public enum SupportAction: Sendable, Equatable {
    case openURL(URL)
    case email(SupportMailDraft)

    public var url: URL? {
        switch self {
        case .openURL(let url): url
        case .email(let draft): draft.mailtoURL
        }
    }
}

/// Acceptance means the system accepted the URL, not that a message or review was submitted.
public enum SupportActionResult: Sendable, Equatable {
    case accepted
    case rejected
    case invalid
}
