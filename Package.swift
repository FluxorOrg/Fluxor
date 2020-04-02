// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Fluxor",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
    ],
    products: [
        .library(
            name: "Fluxor",
            type: .dynamic,
            targets: ["Fluxor"]),
        .library(
            name: "FluxorTestSupport",
            type: .dynamic,
            targets: ["FluxorTestSupport"]),
    ],
    targets: [
        .target(
            name: "AnyEncodable"),
        .testTarget(
            name: "AnyEncodableTests",
            dependencies: ["AnyEncodable"]),
        .target(
            name: "Fluxor",
            dependencies: ["AnyEncodable"]),
        .testTarget(
            name: "FluxorTests",
            dependencies: ["Fluxor"]),
        .target(
            name: "FluxorTestSupport",
            dependencies: ["Fluxor"]),
    ]
)
