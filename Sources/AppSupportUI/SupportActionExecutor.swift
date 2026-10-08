import AppSupportCore
import SwiftUI

/// Kept separate from presentation so URL acceptance can be tested with OpenURLAction.
@MainActor
enum SupportActionExecutor {
    static func execute(
        _ action: SupportAction,
        openURL: OpenURLAction,
        completion: @escaping @MainActor (SupportActionResult) -> Void
    ) {
        let url: URL?
        switch action {
        case .openURL(let destination):
            url = destination.scheme == nil ? nil : destination
        case .email(let draft):
            url = draft.mailtoURL
        }

        guard let url else {
            completion(.invalid)
            return
        }
        openURL(url) { accepted in
            completion(accepted ? .accepted : .rejected)
        }
    }
}
