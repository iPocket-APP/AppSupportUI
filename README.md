# AppSupportUI 2.0

Composable SwiftUI support and About content for **iOS 17+ / macOS 13+**, using **Swift 6.2+**. The package provides two products:

- `AppSupportCore`: Foundation-only, `Sendable` identity, links, diagnostics, mail drafts and resolved copy.
- `AppSupportUI`: reusable labels, action buttons, version rows, an identity header, unwrapped rows and a convenient Form section.

Version **2.0.0** is a breaking API redesign; the previous configuration and section APIs are removed. See [migration](Docs/Migration-2.0.md).

## Installation

```swift
.package(url: "https://github.com/iPocket-APP/AppSupportUI.git", from: "2.0.0")
```

For local package development:

```swift
.package(path: "../AppSupportUI")
```

Add both `AppSupportCore` and `AppSupportUI` products to a UI host. Non-UI support/recovery code can depend on Core alone. Existing remote consumers must explicitly replace the old `2026.x` version requirement with `2.0.0` and migrate their call sites.

## Simple Form

```swift
import AppSupportCore
import AppSupportUI
import SwiftUI

struct SettingsView: View {
    var body: some View {
        let identity = AppIdentity.current(name: "MyApp")
        let content = SupportContent(
            identity: identity,
            links: SupportLinks(
                email: "support@example.com",
                contactURL: URL(string: "https://example.com/contact"),
                privacyURL: URL(string: "https://example.com/privacy"),
                appStoreID: "123456789"
            ),
            copy: .packageDefaults(
                appName: identity.name,
                language: Bundle.main.preferredLocalizations.first
            )
        )
        Form {
            SupportSection(content: content, rows: [.version, .rate, .contactEmail, .privacy])
        }
    }
}
```

Unconfigured or invalid built-in endpoints hide their rows. Email and contact website are separate row kinds, so they can coexist. Numeric App Store IDs may include an `id` prefix. The manual review action opens the App Store; automatic review timing and entitlement decisions stay with the host.

## Cards, navigation and custom content

`SupportRows` has no Section or card wrapper. Hosts select row order and their own container. Repeated row kinds are rendered once.

```swift
VStack {
    SupportRows(content: content, rows: [.version, .contactEmail])
    NavigationLink {
        PrivacyExplanationView()
    } label: {
        SupportRowLabel(title: content.copy.privacy.title, systemImage: "hand.raised", accessory: .none)
    }
    // A host-owned license DisclosureGroup, update button, or business action can follow.
}
```

Use `SupportActionButton` with any host label to retain a custom card's layout and get URL result handling and mail failure recovery. `SupportVersionRow` shares the icon column with action rows, supports a build-number display option, and keeps version values in LTR. `AppIdentityHeader` accepts a host-provided icon. None of these components owns the app's navigation, theme, updater, language manager, or subscription state.

## Every language can be supplied by the host

Only **English and Simplified Chinese** are built in. Unsupported package languages fall back as a whole to English, including Traditional Chinese. To support other languages, supply a complete `SupportCopy` using the host's current language resources:

```swift
let copy = SupportCopy(
    sectionTitle: hostText("support.section"),
    versionTitle: hostText("support.version"),
    unknownVersion: hostText("support.unknown"),
    rate: .init(title: hostText("support.rate")),
    contact: .init(title: hostText("support.email")),
    contactWebsite: .init(title: hostText("support.contactWebsite")),
    privacy: .init(title: hostText("support.privacy")),
    terms: .init(title: hostText("support.terms")),
    website: .init(title: hostText("support.website")),
    mail: .init(
        subject: hostText("support.mail.subject"),
        prompt: hostText("support.mail.prompt"),
        appLabel: hostText("support.mail.app"),
        versionLabel: hostText("support.mail.version"),
        buildLabel: hostText("support.mail.build"),
        systemLabel: hostText("support.mail.system"),
        deviceLabel: hostText("support.mail.device")
    ),
    failure: .init(
        title: hostText("support.failure.title"),
        message: hostText("support.failure.message"),
        copyEmail: hostText("support.failure.copyEmail"),
        copyDiagnostics: hostText("support.failure.copyDiagnostics"),
        contactWebsite: hostText("support.failure.contactWebsite"),
        close: hostText("support.failure.close"),
        copied: hostText("support.failure.copied")
    )
)
```

`hostText` is the host's existing lookup function, not an API in this package. All supplied strings are already resolved and are displayed verbatim, rather than being looked up in the main bundle again. Recreate the copy when the host changes language. Keep content-language selection separate from the formatting locale; UI layout direction comes from the host's SwiftUI environment.

The package's editable source is `Localization/Support.xcstrings`. Its two generated `.lproj/Localizable.strings` resources allow **both standard SwiftPM and Xcode builds** to use compiled localization. After editing, run `python3 Scripts/check-localizations.py --write`; validation uses the same script without `--write`.

## Mail and URL results

`SupportContent.makeMailDraft(diagnostics:)` returns plain recipient, subject and body. `draft.mailtoURL` uses `URLComponents`. The body includes marketing version, build, system and hardware model; hiding the build in a settings row does not remove it from diagnostics. Hosts may supply extra `SupportDiagnostics.Field` values, and can use drafts outside settings without SwiftUI.

```swift
SupportActionButton(
    action: .email(draft), copy: content.copy, contactURL: content.links.contactURL,
    onStart: { action in recordAttempt(action) },
    onResult: { action, result in recordResult(action, result) }
) {
    SupportRowLabel(title: content.copy.contact.title, systemImage: "envelope")
}
```

Rejected/invalid email actions show a recoverable sheet with selectable recipient and body, copy buttons with confirmation, and an optional contact website. Rejected web actions show a localized alert. An `.accepted` result means the system accepted the URL; it does not confirm that a message was sent or a review was submitted. Core never sends mail or performs network requests.

## Manual validation demo

Run `swift run --package-path Examples/SupportDemo AppSupportDemo` on macOS. The isolated example covers English/Chinese/host-supplied Arabic, LTR version text in RTL, native navigation, license disclosure, URL rejection and mail recovery. URL handling is simulated and never opens an external service. The validation-control labels are developer-facing English, separate from the injected support copy.

## Verification

```sh
python3 Scripts/check-localizations.py
swift test -Xswiftc -warnings-as-errors
bash Scripts/verify.sh
```

`verify.sh` runs localization checks, standard-backend unit tests, and strict Swift 6 iOS/macOS generic builds. No deprecated native-backend override or artificial macOS target is required. See [validation and migration record](Docs/Validation-2.0.md) for the actual run results and separate UI/device limitations.

MIT licensed; see [LICENSE](LICENSE).
