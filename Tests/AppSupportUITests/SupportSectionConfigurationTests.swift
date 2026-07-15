import XCTest
@testable import AppSupportUI

final class SupportSectionConfigurationTests: XCTestCase {
    func testReviewURLBuildsWriteReviewLink() {
        let config = SupportSectionConfiguration(appStoreID: "123456789")
        XCTAssertEqual(
            config.reviewURL?.absoluteString,
            "https://apps.apple.com/app/id123456789?action=write-review"
        )
        XCTAssertTrue(config.shouldShowRateRow)
    }

    func testReviewURLNormalizesPrefixAndWhitespace() {
        for value in ["id999", "ID999", "  Id999  "] {
            let config = SupportSectionConfiguration(appStoreID: value)
            XCTAssertEqual(config.resolvedAppStoreID, "999")
            XCTAssertEqual(
                config.reviewURL?.absoluteString,
                "https://apps.apple.com/app/id999?action=write-review"
            )
        }
    }

    func testReviewURLRejectsInvalidIDs() {
        for value in ["", "   ", "id", "ID", "abc123", "123abc", "１２３", "https://apps.apple.com/app/id123"] {
            let config = SupportSectionConfiguration(appStoreID: value)
            XCTAssertNil(config.resolvedAppStoreID, "Expected invalid ID: \(value)")
            XCTAssertNil(config.reviewURL)
            XCTAssertFalse(config.shouldShowRateRow)
        }
    }

    func testRateRowRespectsVisibilityFlag() {
        let config = SupportSectionConfiguration(appStoreID: "123", showsRate: false)
        XCTAssertFalse(config.shouldShowRateRow)
    }

    func testContactRowRequiresValidEmail() {
        XCTAssertTrue(
            SupportSectionConfiguration(supportEmail: " support+ios@example.com ")
                .shouldShowContactRow
        )
        XCTAssertFalse(SupportSectionConfiguration(supportEmail: "   ").shouldShowContactRow)
        XCTAssertFalse(
            SupportSectionConfiguration(supportEmail: "support.example.com")
                .shouldShowContactRow
        )
    }

    func testMailDiagnosticsUseResolvedVersionDisplay() throws {
        let config = SupportSectionConfiguration(
            appName: "Demo",
            versionDisplay: "v9.9 (123)",
            supportEmail: "support@example.com"
        )

        let url = try XCTUnwrap(config.mailtoURL())
        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let body = try XCTUnwrap(components.queryItems?.first(where: { $0.name == "body" })?.value)
        XCTAssertTrue(body.contains("v9.9 (123)"))
    }

    func testVersionDisplayFormat() {
        let display = AppVersionInfo.versionDisplay(
            from: Bundle.module,
            prefix: "v",
            includeBuildNumber: false
        )
        XCTAssertFalse(display.isEmpty)
        XCTAssertTrue(display.hasPrefix("v"))
    }

    @MainActor
    func testExtraRowPreservesExplicitStableID() {
        let row = SupportExtraRow(
            id: "export-diagnostics",
            title: "Export Diagnostics",
            subtitle: "Save a support report",
            systemImage: "square.and.arrow.up"
        ) {}

        XCTAssertEqual(row.id, "export-diagnostics")
    }
}
