import Foundation
import XCTest
@testable import AppSupportUI

final class DeviceInfoTests: XCTestCase {
    func testSystemVersionOmitsZeroPatch() {
        let version = OperatingSystemVersion(majorVersion: 18, minorVersion: 0, patchVersion: 0)
        XCTAssertEqual(DeviceInfo.formattedSystemVersion(version), "18.0")
    }

    func testSystemVersionIncludesNonzeroPatch() {
        let version = OperatingSystemVersion(majorVersion: 18, minorVersion: 1, patchVersion: 2)
        XCTAssertEqual(DeviceInfo.formattedSystemVersion(version), "18.1.2")
    }

    func testSimulatorModelIdentifierTakesPrecedence() {
        XCTAssertEqual(
            DeviceInfo.resolvedModelIdentifier(
                environment: ["SIMULATOR_MODEL_IDENTIFIER": "  iPhone15,2  "]
            ),
            "iPhone15,2"
        )
    }

    func testModelIdentifierFallsBackToUname() {
        XCTAssertFalse(DeviceInfo.resolvedModelIdentifier(environment: [:]).isEmpty)
    }
}
