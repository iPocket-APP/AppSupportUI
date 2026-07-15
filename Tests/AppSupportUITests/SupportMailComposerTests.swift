import XCTest
@testable import AppSupportUI

final class SupportMailComposerTests: XCTestCase {
    func testMailtoURLContainsEmailSubjectAndDiagnostics() throws {
        let diagnostics = SupportMailComposer.Diagnostics(
            appName: "ImageSeal",
            appVersion: "1.2.3",
            systemVersion: "18.0",
            deviceModel: "iPhone15,2"
        )

        let url = try XCTUnwrap(
            SupportMailComposer.mailtoURL(
                email: "contact@example.com",
                subject: "Support for ImageSeal",
                bodyPrompt: "Please describe the issue above this line.",
                diagnostics: diagnostics
            )
        )

        XCTAssertEqual(url.scheme, "mailto")
        XCTAssertTrue(url.absoluteString.hasPrefix("mailto:contact@example.com"))

        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let items = Dictionary(
            uniqueKeysWithValues: (components.queryItems ?? []).map { ($0.name, $0.value ?? "") }
        )

        XCTAssertEqual(items["subject"], "Support for ImageSeal")
        let body = try XCTUnwrap(items["body"])
        XCTAssertTrue(body.contains("Please describe the issue above this line."))
        XCTAssertTrue(body.contains("ImageSeal"))
        XCTAssertTrue(body.contains("1.2.3"))
        XCTAssertTrue(body.contains("18.0"))
        XCTAssertTrue(body.contains("iPhone15,2"))
    }

    func testMailtoURLRejectsEmptyEmail() {
        let url = SupportMailComposer.mailtoURL(
            email: "   ",
            subject: "Hi",
            diagnostics: SupportMailComposer.Diagnostics(
                appName: "App",
                appVersion: "1.0",
                systemVersion: "18.0",
                deviceModel: "x86_64"
            )
        )
        XCTAssertNil(url)
    }

    func testMailtoURLRejectsMalformedEmails() {
        let malformedEmails = [
            "support.example.com",
            "support@@example.com",
            "@example.com",
            "support@",
            "support @example.com",
            "support@exa\nmple.com",
        ]

        for email in malformedEmails {
            XCTAssertNil(
                SupportMailComposer.mailtoURL(
                    email: email,
                    subject: "Support",
                    diagnostics: diagnostics
                ),
                "Expected malformed email to be rejected: \(email.debugDescription)"
            )
        }
    }

    func testMailtoURLAcceptsTrimmedPlusAddressAndUnicodeContent() throws {
        let url = try XCTUnwrap(
            SupportMailComposer.mailtoURL(
                email: "  support+ios@example.com  ",
                subject: "支持 ImageSeal",
                bodyPrompt: "请描述问题。",
                diagnostics: diagnostics
            )
        )

        XCTAssertEqual(url.path, "support+ios@example.com")
        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let items = Dictionary(
            uniqueKeysWithValues: (components.queryItems ?? []).map { ($0.name, $0.value ?? "") }
        )
        XCTAssertEqual(items["subject"], "支持 ImageSeal")
        XCTAssertTrue(try XCTUnwrap(items["body"]).contains("请描述问题。"))
    }

    func testDefaultSubjectUsesAppName() {
        let subject = SupportMailComposer.defaultSubject(appName: "DemoApp")
        XCTAssertTrue(subject.contains("DemoApp"))
    }

    private var diagnostics: SupportMailComposer.Diagnostics {
        SupportMailComposer.Diagnostics(
            appName: "ImageSeal",
            appVersion: "1.2.3",
            systemVersion: "18.0",
            deviceModel: "iPhone15,2"
        )
    }
}
