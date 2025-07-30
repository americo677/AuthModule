// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "AuthModule",
    platforms: [
        .iOS(.v15),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "AuthModule",
            targets: ["AuthModule"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AuthModule",
            dependencies: [],
            path: "Sources",
            linkerSettings: [
                .linkedLibrary("CommonCrypto")
            ]),
        .testTarget(
            name: "AuthModuleTests",
            dependencies: ["AuthModule"],
            path: "Tests"),
    ]
)
