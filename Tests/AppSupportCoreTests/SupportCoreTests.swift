import Foundation
import XCTest
@testable import AppSupportCore

final class SupportCoreTests: XCTestCase {
    private let identity = AppIdentity(name: "Test & + 中文", version: "2.0", build: "42")

    func testVersionPresentationAndBuildAreIndependent() throws {
        XCTAssertEqual(identity.versionDisplay(), "v2.0")
        XCTAssertEqual(identity.versionDisplay(includeBuild: true, prefix: ""), "2.0 (42)")
        XCTAssertEqual(AppIdentity(name: "Demo", version: " ", build: " ").versionDisplay(unknownVersion: "未知"), "v未知")
        let content = SupportContent(identity: identity, links: .init(email: "help@example.com"),
                                     copy: .packageDefaults(appName: identity.name, language: "en"))
        XCTAssertTrue(try XCTUnwrap(content.makeMailDraft()).body.contains("Build: 42"))
    }

    func testReviewIDNormalization() {
        for input in ["12345", " id12345\n", "ID12345"] {
            XCTAssertEqual(SupportLinks(appStoreID: input).reviewURL?.absoluteString,
                           "https://apps.apple.com/app/id12345?action=write-review")
        }
        for input in ["", "id", "123x", "１２３", "123 45", "-1"] {
            XCTAssertNil(SupportLinks(appStoreID: input).reviewURL)
        }
    }

    func testContactNormalizationAndWebEndpoints() {
        XCTAssertEqual(SupportLinks(email: " help+ios@example.com\n").normalizedEmail, "help+ios@example.com")
        for value in ["", "a@", "@b", "a@@b", "a b@c", "a\n@c"] {
            XCTAssertNil(SupportLinks(email: value).normalizedEmail)
        }
        XCTAssertNotNil(SupportLinks.validatedWebURL(URL(string: "https://example.com/contact?a=b")))
        XCTAssertNil(SupportLinks.validatedWebURL(URL(string: "file:///private/test")))
        XCTAssertNil(SupportLinks.validatedWebURL(URL(string: "/relative")))
        XCTAssertNil(SupportLinks.validatedWebURL(nil))
    }

    func testCompiledChineseResourcesAreActuallyResolved() {
        let copy = SupportCopy.packageDefaults(appName: "测试", language: "zh-Hans-CN")
        XCTAssertEqual(copy.contact.title, "联系支持")
        XCTAssertEqual(copy.versionTitle, "版本")
        XCTAssertEqual(copy.rate.title, "为 测试 评分")
        XCTAssertEqual(copy.mail.subject, "测试 使用反馈")
        XCTAssertEqual(copy.mail.systemLabel, "系统")
        XCTAssertEqual(copy.failure.copied, "已复制")
    }

    func testLanguageChangesDoNotReuseAStaleCopy() {
        let english = SupportCopy.packageDefaults(appName: "Demo", language: "en-GB")
        let chinese = SupportCopy.packageDefaults(appName: "Demo", language: "zh_CN")
        let again = SupportCopy.packageDefaults(appName: "Demo", language: "en")
        XCTAssertEqual(english, again)
        XCTAssertNotEqual(english, chinese)
        XCTAssertEqual(english.contact.title, "Contact Support")
    }

    func testUnsupportedLanguagesFallBackAsAWhole() {
        let english = SupportCopy.packageDefaults(appName: "Demo", language: "en")
        for language in ["ar", "it", "es-MX", "zh-Hant", "zh-TW", "xx-ZZ"] {
            XCTAssertEqual(SupportCopy.packageDefaults(appName: "Demo", language: language), english)
        }
    }

    func testHostArabicCopyControlsUIAndTheEntireDraft() throws {
        let copy = SupportCopy(
            sectionTitle: "الدعم", versionTitle: "الإصدار", unknownVersion: "غير معروف",
            rate: .init(title: "التقييم"), contact: .init(title: "الاتصال بالدعم"),
            contactWebsite: .init(title: "موقع الدعم"), privacy: .init(title: "الخصوصية"),
            terms: .init(title: "الشروط"), website: .init(title: "الموقع"),
            mail: .init(subject: "مساعدة", prompt: "صف المشكلة", appLabel: "التطبيق",
                        versionLabel: "الإصدار", buildLabel: "البنية", systemLabel: "النظام", deviceLabel: "الجهاز"),
            failure: .init(title: "تعذر الفتح", message: "انسخ التفاصيل", copyEmail: "نسخ البريد",
                           copyDiagnostics: "نسخ التفاصيل", contactWebsite: "فتح الموقع", close: "إغلاق", copied: "تم النسخ")
        )
        let content = SupportContent(identity: identity, links: .init(email: "help@example.com"), copy: copy)
        let draft = try XCTUnwrap(content.makeMailDraft(diagnostics: .init(systemName: "iOS", systemVersion: "17.0", deviceModel: "iPhone15,2")))
        XCTAssertEqual(content.copy.contact.title, "الاتصال بالدعم")
        XCTAssertEqual(draft.subject, "مساعدة")
        for label in ["التطبيق", "الإصدار", "البنية", "النظام", "الجهاز"] { XCTAssertTrue(draft.body.contains(label + ":")) }
        XCTAssertFalse(draft.body.contains("Version:"))
    }

    func testMailURLRoundTripsReservedCharactersAndNewlines() throws {
        let draft = SupportMailDraft(recipient: "help+ios@example.com", subject: "中文 & + ? # %", body: "第一行\n第二行 & + ? # %")
        let url = try XCTUnwrap(draft.mailtoURL)
        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))
        XCTAssertEqual(components.scheme, "mailto")
        XCTAssertEqual(components.path, draft.recipient)
        XCTAssertEqual(components.queryItems?.first(where: { $0.name == "subject" })?.value, draft.subject)
        XCTAssertEqual(components.queryItems?.first(where: { $0.name == "body" })?.value, draft.body)
        XCTAssertNil(SupportMailDraft(recipient: "invalid", subject: "", body: "").mailtoURL)
    }

    func testDiagnosticsHavePlatformAndHostFields() throws {
        let content = SupportContent(identity: identity, links: .init(email: "help@example.com"),
                                     copy: .packageDefaults(appName: identity.name, language: "en"))
        let diagnostics = SupportDiagnostics(systemName: "macOS", systemVersion: "13.0", deviceModel: "MacBookPro18,3",
                                             additionalFields: [.init(label: "Sync", value: "Disabled")])
        let draft = try XCTUnwrap(content.makeMailDraft(diagnostics: diagnostics))
        XCTAssertTrue(draft.body.contains("System: macOS 13.0"))
        XCTAssertTrue(draft.body.contains("Device: MacBookPro18,3"))
        XCTAssertTrue(draft.body.contains("Sync: Disabled"))
        XCTAssertFalse(draft.body.contains("iOS Version"))
    }

    func testMissingContactDoesNotProduceDraft() {
        let content = SupportContent(identity: identity, links: .init(contactURL: URL(string: "https://example.com")),
                                     copy: .packageDefaults(appName: identity.name, language: "en"))
        XCTAssertNil(content.makeMailDraft())
        XCTAssertNotNil(content.links.contactURL)
    }

    func testSystemVersionsAndSimulatorModel() {
        XCTAssertEqual(SupportDiagnostics.formattedSystemVersion(.init(majorVersion: 17, minorVersion: 1, patchVersion: 0)), "17.1")
        XCTAssertEqual(SupportDiagnostics.formattedSystemVersion(.init(majorVersion: 17, minorVersion: 1, patchVersion: 2)), "17.1.2")
        XCTAssertEqual(SupportDiagnostics.modelIdentifier(environment: ["SIMULATOR_MODEL_IDENTIFIER": " iPhone15,2 "]), "iPhone15,2")
        let current = SupportDiagnostics.current()
        XCTAssertFalse(current.deviceModel.isEmpty)
        #if os(macOS)
        XCTAssertEqual(current.systemName, "macOS")
        XCTAssertNotEqual(current.deviceModel, "arm64")
        XCTAssertNotEqual(current.deviceModel, "x86_64")
        #endif
    }

    func testPublicContentCanCrossConcurrencyBoundaries() {
        func requireSendable<T: Sendable>(_ value: T) { _ = value }
        requireSendable(SupportContent(identity: identity, links: .init(), copy: .packageDefaults(appName: "Test", language: "en")))
        requireSendable(SupportDiagnostics.current())
        requireSendable(SupportAction.email(.init(recipient: "help@example.com", subject: "", body: "")))
    }
}
