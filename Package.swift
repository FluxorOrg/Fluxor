// swift-tools-version:5.2

import PackageDescription

var products: [Product] = [
    .library(
        name: "Fluxor",
        targets: ["Fluxor"]),
    .library(
        name: "FluxorTestSupport",
        targets: ["FluxorTestSupport"]),
]
#if canImport(SwiftUI)
products.append(.library(
    name: "FluxorSwiftUI",
    targets: ["FluxorSwiftUI"]))
#endif

var dependencies: [Package.Dependency] = []
var fluxorTargetDependencies: [Target.Dependency] = ["AnyCodable"]
#if !canImport(Combine)
dependencies.append(.package(url: "https://github.com/OpenCombine/OpenCombine.git", from: "0.12.0"))
fluxorTargetDependencies.append(contentsOf: [
    "OpenCombine",
    .product(name: "OpenCombineDispatch", package: "OpenCombine"),
])
#endif

let package = Package(
    name: "Fluxor",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: products,
    dependencies: dependencies,
    targets: [
        .target(
            name: "AnyCodable"),
        .testTarget(
            name: "AnyCodableTests",
            dependencies: ["AnyCodable"]),
        .target(
            name: "Fluxor",
            dependencies: fluxorTargetDependencies),
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
