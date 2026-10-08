# Migrating to AppSupportUI 2.0

The 2026 date-versioned API is removed. New package releases use SemVer starting at 2.0.0. Old `from: "2026.7.16"` requirements cannot select 2.0.0; every remote consumer needs an explicit requirement change and migrated call sites.

## API replacements

| Previous API | Replacement |
|---|---|
| `SupportSectionConfiguration` | `AppIdentity` + `SupportLinks` + complete `SupportCopy`, composed into `SupportContent` |
| `SupportSettingsSection` | `SupportSection` for a Form; `SupportRows` or individual components for custom containers |
| `SettingsActionRow` | `SupportActionButton` wrapping `SupportRowLabel` or a host-owned label |
| `SupportExtraRow` | Normal SwiftUI composition, including NavigationLink and DisclosureGroup |
| `AppVersionInfo` | `AppIdentity.current(bundle:)` and `versionDisplay(...)` |
| `DeviceInfo` | `SupportDiagnostics.current()` |
| `SupportMailComposer` | `SupportContent.makeMailDraft(diagnostics:)` and `SupportMailDraft.mailtoURL` |

Add both package products to the app target and import both modules. Preserve each host's row visibility, branding, native navigation, accessibility identifiers and review event timing. `SupportSectionStyle` owns colors and sizing; custom icons/content use `SupportRowLabel` directly. Build numbers in diagnostics are independent of display options.

## Languages

Hosts with only English/Simplified Chinese may use `SupportCopy.packageDefaults`, passing the actual host content language rather than an unrelated regional locale. Hosts with more languages construct a complete copy from their own resources. Cover failure, confirmation and diagnostic text too. Existing host language-management and refresh policies remain authoritative.

## First consumer migrations

The eight selected apps were migrated and validated against the same local package checkout. Their source changes remain in their local app repositories for review during the next app update. Seven use the GitHub package with `upToNextMajorVersion`, minimum `2.0.0`; ImageSeal retains its local reference. Existing unrelated dependency pins and worktree changes are retained.

| Host | Dependency | Migration focus |
|---|---|---|
| ImageSeal | Local `../AppSupportUI` | Existing Form and brand colors |
| PuzzleWall | GitHub `2.0.0..<3.0.0` | Complete copy from nine host languages |
| PhoneLive 3D | GitHub `2.0.0..<3.0.0` | Minimal Form and existing row visibility |
| SnapFrame / PocketDraft | GitHub `2.0.0..<3.0.0` | Existing localized brand and generator configuration |
| Weather Island | GitHub `2.0.0..<3.0.0` | Original card/label layout, shared mail draft and action handling |
| PocketRemote | GitHub `2.0.0..<3.0.0` | Twelve languages, removal of custom support/RTL wrapper |
| RefShot | GitHub `2.0.0..<3.0.0` | Website support, host Legal grouping and local license disclosure |
| PocketDock | GitHub `2.0.0..<3.0.0` | macOS 13, twelve languages, shared draft and language refresh |

Resolve packages when opening each migrated app in Xcode and review the resulting lockfile against the actual GitHub tag. Lockfiles must come from package resolution. SnapFrame's `project.yml` and project file both carry the new requirement. ImageSeal still requires the sibling checkout. Package publication and application releases are separate operations; see the [validation record](Validation-2.0.md) for the checks completed before publication.

## Product boundaries

Automatic review prompting, Sparkle, Pro entitlement display, native privacy explanation, app-specific diagnostics and data reset remain host-owned. The generic support action handles URL acceptance and its own recovery UI. Custom actions can use ordinary host buttons; custom navigation uses a native NavigationLink with a shared label.
