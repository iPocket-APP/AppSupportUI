# AppSupportUI 2.0 validation

Validated on 2026-10-08 with Xcode 27.0 / Swift 6.4. The manifest retains the Swift 6.2 tools baseline and iOS 17 / macOS 13 deployment targets. Swift 6.2 itself was not separately exercised.

## Package checks

- Standard-backend `swift test -Xswiftc -warnings-as-errors`: 18 tests passed (12 Core, 6 UI action/row tests).
- Generic iOS and macOS builds passed with Swift 6, complete concurrency checking, and warnings treated as errors. The macOS build included arm64 and x86_64.
- Localization source integrity and generated-resource consistency passed for all 28 English/Simplified Chinese keys. Tests read the actual compiled resources and exercise language switching, unsupported-language fallback, and a complete host-supplied Arabic copy.
- Mail tests cover Chinese, newlines, `&`, `+`, recipient validation, build information independent of UI display, and host diagnostic fields. Action tests cover accepted, rejected, invalid and custom-scheme URLs, mail payloads, and configured row order/filtering.
- The standalone macOS demo compiled. Its native UI was checked in English, Simplified Chinese, and host-supplied Arabic, including RTL/LTR version values, mail fallback, copy confirmations, localized website failure, simulated accepted results, and native navigation.

The demo uses simulated URL handling. It does not send mail or contact external services. Its license disclosure is available for manual inspection; expansion was not verified in this run.

## Host integration checks

These builds used local package overrides before switching remote consumers to the GitHub version requirement.

| Host | Evidence |
|---|---|
| ImageSeal | Generic iOS build passed; existing local package reference retained. |
| PuzzleWall | Generic iOS app and Messages targets built; all 28 support strings in nine compiled host languages matched their catalog values. |
| PhoneLive 3D | Generic iOS app, broadcast extension, and package dependencies built. |
| SnapFrame / PocketDraft | Generic iOS build passed; generator configuration migrated with the project file. |
| Weather Island | Generic iOS build passed using an isolated project graph with unused QA/probe project references disconnected. App targets, build phases, configurations, and source inputs were preserved. The original project graph was left intact. |
| PocketRemote | Generic iOS app built; simulator test targets compiled. Those host tests were not executed. Existing review-event timing was preserved. |
| RefShot | macOS Debug build passed; compiled resources were checked across ten host languages, including Mexican Spanish. Existing unrelated catalog issues were retained. |
| PocketDock | Project syntax, Swift syntax, catalog coverage and compiled localization lookups passed for twelve languages. No app command-line build was run, in accordance with its project instructions. |

## Remaining checks during app updates

Resolve each app's GitHub dependency in Xcode, review its local migration diff, and run its normal build and release checks. No app repository was pushed by this package release.

No migrated production app was installed, launched, or exercised on a physical device during this work. Real mail-client handling, production-app UI, iOS RTL interaction, narrow widths and accessibility text sizes need focused app validation. The package demo and build evidence do not establish those outcomes. PocketDock's full build and runtime language refresh also remain to be checked when authorized.
