// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "AppSupportDemo",
    platforms: [.macOS(.v13)],
    dependencies: [.package(path: "../..")],
    targets: [.executableTarget(name: "AppSupportDemo", dependencies: [
        .product(name: "AppSupportCore", package: "AppSupportUI"),
        .product(name: "AppSupportUI", package: "AppSupportUI"),
    ])]
)
