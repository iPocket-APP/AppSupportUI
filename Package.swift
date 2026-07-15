// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "AppSupportUI",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "AppSupportUI",
            targets: ["AppSupportUI"]
        ),
    ],
    targets: [
        .target(
            name: "AppSupportUI",
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "AppSupportUITests",
            dependencies: ["AppSupportUI"]
        ),
    ]
)
