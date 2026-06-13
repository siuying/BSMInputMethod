// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "BSMCore",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "BSMCore", targets: ["BSMCore"]),
    ],
    targets: [
        .target(name: "BSMCore"),
        .testTarget(name: "BSMCoreTests", dependencies: ["BSMCore"]),
    ]
)
