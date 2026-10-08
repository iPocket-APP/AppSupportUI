import Foundation

/// Product identity supplied by the host, independent of presentation and localization.
public struct AppIdentity: Sendable, Equatable {
    public var name: String
    public var version: String
    public var build: String?

    public init(name: String, version: String, build: String? = nil) {
        self.name = name
        self.version = version.trimmingCharacters(in: .whitespacesAndNewlines)
        self.build = build?.trimmingCharacters(in: .whitespacesAndNewlines)
        if self.build?.isEmpty == true { self.build = nil }
    }

    public static func current(name: String? = nil, bundle: Bundle = .main) -> Self {
        func value(_ key: String) -> String? {
            guard let result = (bundle.object(forInfoDictionaryKey: key) as? String)?
                .trimmingCharacters(in: .whitespacesAndNewlines), !result.isEmpty else { return nil }
            return result
        }
        let suppliedName = name?.trimmingCharacters(in: .whitespacesAndNewlines)
        return Self(
            name: suppliedName.flatMap { $0.isEmpty ? nil : $0 }
                ?? value("CFBundleDisplayName") ?? value("CFBundleName") ?? "App",
            version: value("CFBundleShortVersionString") ?? "",
            build: value("CFBundleVersion")
        )
    }

    public func versionDisplay(
        includeBuild: Bool = false, prefix: String = "v", unknownVersion: String = "Unknown"
    ) -> String {
        let value = prefix + (version.isEmpty ? unknownVersion : version)
        return includeBuild ? build.map { "\(value) (\($0))" } ?? value : value
    }
}
