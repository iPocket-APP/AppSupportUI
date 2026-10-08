import AppSupportCore
import Foundation
import SwiftUI
import XCTest
@testable import AppSupportUI

final class SupportActionExecutorTests: XCTestCase {
    @MainActor
    func testHandledURLReportsAcceptance() {
        let destination = URL(string: "https://example.com/privacy")!
        var openedURL: URL?
        var result: SupportActionResult?
        let openURL = OpenURLAction { url in
            openedURL = url
            return .handled
        }

        SupportActionExecutor.execute(.openURL(destination), openURL: openURL) { result = $0 }

        XCTAssertEqual(openedURL, destination)
        XCTAssertEqual(result, .accepted)
    }

    @MainActor
    func testDiscardedURLReportsRejection() {
        var result: SupportActionResult?
        SupportActionExecutor.execute(
            .openURL(URL(string: "https://example.com/support")!),
            openURL: OpenURLAction { _ in .discarded }
        ) { result = $0 }

        XCTAssertEqual(result, .rejected)
    }

    @MainActor
    func testInvalidMailDraftDoesNotCallTheSystem() {
        var systemCalls = 0
        var result: SupportActionResult?
        SupportActionExecutor.execute(
            .email(SupportMailDraft(recipient: "invalid", subject: "Support", body: "Details")),
            openURL: OpenURLAction { _ in
                systemCalls += 1
                return .handled
            }
        ) { result = $0 }

        XCTAssertEqual(systemCalls, 0)
        XCTAssertEqual(result, .invalid)
    }

    @MainActor
    func testMailActionPreservesTheResolvedDraftAndReportsRejection() throws {
        let draft = SupportMailDraft(
            recipient: "support+ios@example.com",
            subject: "支持 Demo",
            body: "版本: 1.2\nBuild: 42"
        )
        var openedURL: URL?
        var result: SupportActionResult?
        SupportActionExecutor.execute(.email(draft), openURL: OpenURLAction { url in
            openedURL = url
            return .discarded
        }) { result = $0 }

        XCTAssertEqual(openedURL, draft.mailtoURL)
        let components = try XCTUnwrap(openedURL.flatMap {
            URLComponents(url: $0, resolvingAgainstBaseURL: false)
        })
        XCTAssertEqual(components.queryItems?.first(where: { $0.name == "body" })?.value, draft.body)
        XCTAssertEqual(result, .rejected)
    }

    @MainActor
    func testRelativeURLIsInvalidWhileAnExplicitHostSchemeIsAllowed() {
        var openedURLs: [URL] = []
        var results: [SupportActionResult] = []
        let openURL = OpenURLAction { url in
            openedURLs.append(url)
            return .handled
        }
        let customURL = URL(string: "demo-support://help")!

        SupportActionExecutor.execute(.openURL(URL(string: "/privacy")!), openURL: openURL) { results.append($0) }
        SupportActionExecutor.execute(.openURL(customURL), openURL: openURL) { results.append($0) }

        XCTAssertEqual(openedURLs, [customURL])
        XCTAssertEqual(results, [.invalid, .accepted])
    }

    @MainActor
    func testAvailableRowsKeepRequestedOrderAndRemoveDuplicateOrInvalidRows() {
        let content = SupportContent(
            identity: AppIdentity(name: "Demo", version: "1.0"),
            links: SupportLinks(
                email: "bad-email",
                contactURL: URL(string: "demo://help"),
                privacyURL: URL(string: "https://example.com/privacy"),
                websiteURL: URL(string: "https://example.com"),
                appStoreID: "123"
            ),
            copy: .packageDefaults(appName: "Demo", language: "en")
        )

        XCTAssertEqual(
            SupportRows.availableRows(
                content: content,
                rows: [.website, .contactEmail, .privacy, .website, .contactWebsite, .terms, .rate, .version]
            ),
            [.website, .privacy, .rate, .version]
        )
        XCTAssertTrue(SupportRows.availableRows(content: content, rows: []).isEmpty)
    }
}
