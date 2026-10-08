import Foundation
import Darwin

/// A diagnostic snapshot. Business-specific fields are explicitly supplied by the host.
public struct SupportDiagnostics: Sendable, Equatable {
    public struct Field: Sendable, Equatable {
        public var label: String
        public var value: String
        public init(label: String, value: String) { self.label = label; self.value = value }
    }

    public var systemName: String
    public var systemVersion: String
    public var deviceModel: String
    public var additionalFields: [Field]

    public init(
        systemName: String, systemVersion: String, deviceModel: String, additionalFields: [Field] = []
    ) {
        self.systemName = systemName
        self.systemVersion = systemVersion
        self.deviceModel = deviceModel
        self.additionalFields = additionalFields
    }

    public static func current(additionalFields: [Field] = []) -> Self {
        #if targetEnvironment(macCatalyst)
        let system = "Mac Catalyst"
        #elseif os(macOS)
        let system = "macOS"
        #else
        let system = "iOS"
        #endif
        return Self(systemName: system,
                    systemVersion: formattedSystemVersion(ProcessInfo.processInfo.operatingSystemVersion),
                    deviceModel: modelIdentifier(environment: ProcessInfo.processInfo.environment),
                    additionalFields: additionalFields)
    }

    static func formattedSystemVersion(_ version: OperatingSystemVersion) -> String {
        let value = "\(version.majorVersion).\(version.minorVersion)"
        return version.patchVersion == 0 ? value : "\(value).\(version.patchVersion)"
    }

    static func modelIdentifier(environment: [String: String]) -> String {
        if let model = environment["SIMULATOR_MODEL_IDENTIFIER"]?
            .trimmingCharacters(in: .whitespacesAndNewlines), !model.isEmpty { return model }
        #if os(macOS) || targetEnvironment(macCatalyst)
        var size = 0
        if sysctlbyname("hw.model", nil, &size, nil, 0) == 0, size > 0 {
            var buffer = [CChar](repeating: 0, count: size)
            if sysctlbyname("hw.model", &buffer, &size, nil, 0) == 0 {
                let bytes = buffer.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) }
                let model = String(decoding: bytes, as: UTF8.self)
                if !model.isEmpty { return model }
            }
        }
        #endif
        var system = utsname()
        guard uname(&system) == 0 else { return "Unknown" }
        let machineSize = MemoryLayout.size(ofValue: system.machine)
        return withUnsafePointer(to: &system.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: machineSize) { String(cString: $0) }
        }
    }
}
