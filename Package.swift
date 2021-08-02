// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Fluxor",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "Fluxor",
            targets: ["Fluxor"]),
        .library(
            name: "FluxorTestSupport",
            targets: ["FluxorTestSupport"]),
        .library(
            name: "FluxorSwiftUI",
            targets: ["FluxorSwiftUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/OpenCombine/OpenCombine.git", from: "0.12.0"),
    ],
    targets: [
        .target(
            name: "AnyCodable"),
        .testTarget(
            name: "AnyCodableTests",
            dependencies: ["AnyCodable"]),
        .target(
            name: "Fluxor",
            dependencies: ["AnyCodable", .product(name: "OpenCombineShim", package: "OpenCombine")]),
        .testTarget(
            name: "FluxorTests",
            dependencies: ["Fluxor", "FluxorTestSupport"]),
        .target(
            name: "FluxorTestSupport",
            dependencies: ["Fluxor"]),
        .target(
            name: "FluxorSwiftUI",
            dependencies: ["Fluxor"]),
        .testTarget(
            name: "FluxorSwiftUITests",
            dependencies: ["FluxorSwiftUI", "FluxorTestSupport"]),
    ])
