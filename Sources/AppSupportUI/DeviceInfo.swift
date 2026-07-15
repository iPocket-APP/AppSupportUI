import Foundation

/// Lightweight device helpers used by support mail diagnostics.
public enum DeviceInfo {
    /// Machine identifier from `uname`, e.g. `"iPhone15,2"`.
    public static var modelIdentifier: String {
        resolvedModelIdentifier(environment: ProcessInfo.processInfo.environment)
    }

    /// Human-readable OS version, e.g. `"18.0"` or `"18.1.2"`.
    public static var systemVersion: String {
        formattedSystemVersion(ProcessInfo.processInfo.operatingSystemVersion)
    }

    static func resolvedModelIdentifier(environment: [String: String]) -> String {
        if let simulatorModel = environment["SIMULATOR_MODEL_IDENTIFIER"]?
            .trimmingCharacters(in: .whitespacesAndNewlines),
            !simulatorModel.isEmpty
        {
            return simulatorModel
        }

        var systemInfo = utsname()
        uname(&systemInfo)
        let machineSize = MemoryLayout.size(ofValue: systemInfo.machine)
        return withUnsafePointer(to: &systemInfo.machine) { pointer in
            pointer.withMemoryRebound(
                to: CChar.self,
                capacity: machineSize
            ) {
                String(cString: $0)
            }
        }
    }

    static func formattedSystemVersion(_ version: OperatingSystemVersion) -> String {
        let base = "\(version.majorVersion).\(version.minorVersion)"
        if version.patchVersion == 0 {
            return base
        }
        return "\(base).\(version.patchVersion)"
    }
}
