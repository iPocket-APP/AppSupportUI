import Foundation

/// Reads marketing / build version info from a bundle.
public enum AppVersionInfo {
    /// `CFBundleShortVersionString`, e.g. `"1.0"`.
    public static func shortVersion(from bundle: Bundle = .main) -> String {
        (bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nilIfEmpty
            ?? String(localized: "Unknown", bundle: .module)
    }

    /// `CFBundleVersion`, e.g. `"42"`.
    public static func buildNumber(from bundle: Bundle = .main) -> String? {
        (bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nilIfEmpty
    }

    /// Display name: `CFBundleDisplayName` → `CFBundleName` → fallback.
    public static func appDisplayName(from bundle: Bundle = .main, fallback: String = "App") -> String {
        if let display = (bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nilIfEmpty
        {
            return display
        }
        if let name = (bundle.object(forInfoDictionaryKey: "CFBundleName") as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nilIfEmpty
        {
            return name
        }
        return fallback
    }

    /// Formats a settings-style version string, e.g. `"v1.0"` or `"v1.0 (42)"`.
    public static func versionDisplay(
        from bundle: Bundle = .main,
        prefix: String = "v",
        includeBuildNumber: Bool = false
    ) -> String {
        let short = shortVersion(from: bundle)
        if includeBuildNumber, let build = buildNumber(from: bundle) {
            return "\(prefix)\(short) (\(build))"
        }
        return "\(prefix)\(short)"
    }
}

extension String {
    fileprivate var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
