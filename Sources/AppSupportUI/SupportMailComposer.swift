import Foundation

/// Builds `mailto:` URLs with a diagnostic footer suitable for support inboxes.
public enum SupportMailComposer {
    public struct Diagnostics: Sendable, Equatable {
        public var appName: String
        public var appVersion: String
        public var systemVersion: String
        public var deviceModel: String

        public init(
            appName: String,
            appVersion: String,
            systemVersion: String = DeviceInfo.systemVersion,
            deviceModel: String = DeviceInfo.modelIdentifier
        ) {
            self.appName = appName
            self.appVersion = appVersion
            self.systemVersion = systemVersion
            self.deviceModel = deviceModel
        }

        /// Collects diagnostics from the main bundle and current device.
        public static func current(appName: String? = nil, appVersion: String? = nil) -> Diagnostics {
            Diagnostics(
                appName: appName ?? AppVersionInfo.appDisplayName(),
                appVersion: appVersion ?? AppVersionInfo.shortVersion()
            )
        }
    }

    /// Creates a `mailto:` URL, or `nil` if the email / components are invalid.
    public static func mailtoURL(
        email: String,
        subject: String,
        bodyPrompt: String? = nil,
        diagnostics: Diagnostics
    ) -> URL? {
        guard let normalizedEmail = normalizedEmail(email) else { return nil }

        let prompt = bodyPrompt
            ?? String(localized: "Please describe the issue above this line.", bundle: .module)
        let appLabel = String(localized: "App", bundle: .module)
        let versionLabel = String(localized: "Version", bundle: .module)
        let systemLabel = String(localized: "iOS Version", bundle: .module)
        let deviceLabel = String(localized: "Device", bundle: .module)

        let body = """


        \(prompt)
        ---
        \(appLabel): \(diagnostics.appName)
        \(versionLabel): \(diagnostics.appVersion)
        \(systemLabel): \(diagnostics.systemVersion)
        \(deviceLabel): \(diagnostics.deviceModel)
        """

        var components = URLComponents()
        components.scheme = "mailto"
        components.path = normalizedEmail
        components.queryItems = [
            URLQueryItem(name: "subject", value: subject),
            URLQueryItem(name: "body", value: body),
        ]
        return components.url
    }

    static func normalizedEmail(_ email: String) -> String? {
        let candidate = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !candidate.isEmpty else { return nil }
        guard !candidate.unicodeScalars.contains(where: {
            CharacterSet.whitespacesAndNewlines.contains($0)
                || CharacterSet.controlCharacters.contains($0)
        }) else {
            return nil
        }

        let parts = candidate.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == 2, !parts[0].isEmpty, !parts[1].isEmpty else { return nil }
        return candidate
    }

    /// Localized subject: `"Support for {appName}"`.
    public static func defaultSubject(appName: String) -> String {
        String(localized: "Support for \(appName)", bundle: .module)
    }
}
