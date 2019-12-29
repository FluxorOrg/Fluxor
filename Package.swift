// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Fluxor",
    platforms: [
        .macOS(.v10_15),
        .iOS("13.0"),
        .tvOS("13.0"),
    ],
    products: [
        .library(
            name: "Fluxor",
            targets: ["Fluxor"]),
    ],
    targets: [
        .target(
            name: "Fluxor",
            dependencies: []),
        .testTarget(
            name: "FluxorTests",
            dependencies: ["Fluxor"]),
    ]
)
