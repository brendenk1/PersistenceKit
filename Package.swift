// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PersistenceKit",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "PersistenceKit",
            targets: ["PersistenceKit"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "PersistenceKit",
            dependencies: []),
        .testTarget(
            name: "PersistenceKitTests",
            dependencies: ["PersistenceKit"],
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
