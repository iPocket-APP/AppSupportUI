# AppSupportUI

Reusable SwiftUI **Settings → Support** section for iOS and iPadOS apps.

Drop it into any `Form` / `List`, inject app-specific email, privacy URL, App Store ID, and theme colors.

Current release: **2026.07.16**

## Requirements

- iOS 17+
- Swift 6.2+

## Install

In Xcode, choose **File → Add Package Dependencies…** and enter:

```text
https://github.com/iPocket-APP/AppSupportUI.git
```

Or add the dependency to another package’s `Package.swift`:

```swift
.package(
    url: "https://github.com/iPocket-APP/AppSupportUI.git",
    from: "2026.7.16"
)
```

Then add the `AppSupportUI` product to your app target.

For local development, use `.package(path: "../AppSupportUI")` instead.

## Usage

```swift
import AppSupportUI
import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            SupportSettingsSection(
                configuration: SupportSectionConfiguration(
                    appName: "MyApp",
                    supportEmail: "support@example.com",
                    privacyPolicyURL: URL(string: "https://example.com/privacy")!,
                    termsOfUseURL: URL(string: "https://example.com/terms"),
                    appStoreID: "123456789",
                    contactSubtitle: "Get help with exports",
                    style: SupportSectionStyle(
                        versionTint: .cyan,
                        rateTint: .orange,
                        contactTint: .cyan,
                        privacyTint: .mint
                    )
                )
            )
        }
    }
}
```

### Built-in rows (shown when configured)

| Row | Shown when |
|-----|------------|
| Version | `showsVersion` (default `true`) |
| Rate | `showsRate` + valid numeric App Store ID |
| Contact Support | valid `supportEmail` set |
| Privacy Policy | `privacyPolicyURL` set |
| Terms of Use | `termsOfUseURL` set |
| Website | `websiteURL` set |
| Extra rows | `extraRows` non-empty |

### App Store reviews

- The Rate row opens `https://apps.apple.com/app/id{ID}?action=write-review`.
- IDs may be numeric or use an optional case-insensitive `id` prefix.
- The row is hidden when the ID is missing or invalid.

The package intentionally does not call `requestReview()` from a button. Host apps should
trigger system review prompts at an appropriate moment in their own product flow.

### Extra rows

Extra rows require a stable ID because the configuration may be recreated during SwiftUI
updates:

```swift
SupportExtraRow(
    id: "export-diagnostics",
    title: "Export Diagnostics",
    subtitle: "Save a support report",
    systemImage: "square.and.arrow.up"
) {
    exportDiagnostics()
}
```

### Mail diagnostics

Contact opens a `mailto:` draft with:

```
Please describe the issue above this line.
---
App: …
Version: …
iOS Version: …
Device: …
```

## ImageSeal example

```swift
SupportSettingsSection(configuration: .imageSeal)
```

See the host app’s `SupportSectionConfiguration` extension for brand colors and product copy.

## Development verification

Because the package product is iOS-only, host-side unit tests explicitly set a modern
macOS compilation target:

```sh
swift test -Xswiftc -target -Xswiftc "$(uname -m)-apple-macosx14.0"
```

The release gate is an iOS generic-destination build using Swift 6, complete strict
concurrency checking, and warnings as errors.

## License

AppSupportUI is available under the [MIT License](LICENSE).
