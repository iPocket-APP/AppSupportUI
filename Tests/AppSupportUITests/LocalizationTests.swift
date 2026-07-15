import Foundation
import XCTest
@testable import AppSupportUI

final class LocalizationTests: XCTestCase {
    func testSimplifiedChineseDiagnosticLabelsInCatalog() throws {
        let catalogURL = try XCTUnwrap(
            Bundle.module.url(forResource: "Localizable", withExtension: "xcstrings")
        )
        let data = try Data(contentsOf: catalogURL)
        let catalog = try XCTUnwrap(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )
        let strings = try XCTUnwrap(catalog["strings"] as? [String: Any])

        XCTAssertEqual(try simplifiedChineseValue(for: "App", strings: strings), "应用")
        XCTAssertEqual(
            try simplifiedChineseValue(for: "iOS Version", strings: strings),
            "iOS 版本"
        )
    }

    private func simplifiedChineseValue(
        for key: String,
        strings: [String: Any]
    ) throws -> String {
        let entry = try XCTUnwrap(strings[key] as? [String: Any])
        let localizations = try XCTUnwrap(entry["localizations"] as? [String: Any])
        let simplifiedChinese = try XCTUnwrap(localizations["zh-Hans"] as? [String: Any])
        let stringUnit = try XCTUnwrap(simplifiedChinese["stringUnit"] as? [String: Any])
        return try XCTUnwrap(stringUnit["value"] as? String)
    }
}
