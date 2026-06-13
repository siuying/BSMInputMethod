// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "BSMCore",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "BSMCore", targets: ["BSMCore"]),
        .library(name: "BSMCandidateUI", targets: ["BSMCandidateUI"]),
        .library(name: "BSMDictionarySQLite", targets: ["BSMDictionarySQLite"]),
        .executable(name: "bsm-db-build", targets: ["BSMDatabaseBuilder"]),
    ],
    dependencies: [
        .package(url: "https://github.com/stephencelis/SQLite.swift", from: "0.15.3"),
    ],
    targets: [
        .target(name: "BSMCore"),
        .testTarget(name: "BSMCoreTests", dependencies: ["BSMCore"]),

        .target(name: "BSMCandidateUI", dependencies: ["BSMCore"]),
        .testTarget(name: "BSMCandidateUITests", dependencies: ["BSMCandidateUI", "BSMCore"]),

        // SQLite.swift-backed dictionary, kept behind the BSMCore boundary.
        .target(
            name: "BSMDictionarySQLite",
            dependencies: ["BSMCore", .product(name: "SQLite", package: "SQLite.swift")]
        ),
        .testTarget(
            name: "BSMDictionarySQLiteTests",
            dependencies: ["BSMDictionarySQLite", "BSMCore"]
        ),

        // Database builder: pure logic lives in the library so it is testable;
        // the executable is a thin CLI entry point. (ADR 0005)
        .target(
            name: "BSMDatabaseBuilderLib",
            dependencies: [.product(name: "SQLite", package: "SQLite.swift")]
        ),
        .executableTarget(
            name: "BSMDatabaseBuilder",
            dependencies: ["BSMDatabaseBuilderLib"]
        ),
        .testTarget(
            name: "BSMDatabaseBuilderTests",
            dependencies: ["BSMDatabaseBuilderLib"]
        ),
    ]
)
