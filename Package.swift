// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "AppSupportUI",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v13),
    ],
    products: [
        .library(name: "AppSupportCore", targets: ["AppSupportCore"]),
        .library(
            name: "AppSupportUI",
            targets: ["AppSupportUI"]
        ),
    ],
    targets: [
        .target(name: "AppSupportCore", resources: [.process("Resources")]),
        .target(
            name: "AppSupportUI",
            dependencies: ["AppSupportCore"]
        ),
        .testTarget(name: "AppSupportCoreTests", dependencies: ["AppSupportCore"]),
        .testTarget(
            name: "AppSupportUITests",
            dependencies: ["AppSupportUI"]
        ),
    ]
)
