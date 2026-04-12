// swift-tools-version: 6.2

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "Fluxor",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .tvOS(.v17),
        .watchOS(.v10),
        .macCatalyst(.v17),
    ],
    products: [
        .library(
            name: "Fluxor",
            targets: ["Fluxor"]
        ),
        .library(
            name: "FluxorSwiftUI",
            targets: ["FluxorSwiftUI"]
        ),
        .library(
            name: "FluxorMacros",
            targets: ["FluxorMacros"]
        ),
        .library(
            name: "FluxorTestSupport",
            targets: ["FluxorTestSupport"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "603.0.0-latest"),
    ],
    targets: [
        .target(name: "AnyCodable"),
        .testTarget(
            name: "AnyCodableTests",
            dependencies: ["AnyCodable"]
        ),
        .target(name: "Fluxor"),
        .target(
            name: "FluxorSwiftUI",
            dependencies: ["Fluxor"]
        ),
        .macro(
            name: "FluxorMacrosImplementation",
            dependencies: [
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "FluxorMacros",
            dependencies: ["FluxorMacrosImplementation"]
        ),
        .target(
            name: "FluxorTestSupport",
            dependencies: ["Fluxor"]
        ),
        .testTarget(
            name: "FluxorTests",
            dependencies: [
                "Fluxor",
                "FluxorTestSupport",
            ]
        ),
        .testTarget(
            name: "FluxorSwiftUITests",
            dependencies: [
                "Fluxor",
                "FluxorSwiftUI",
                "FluxorTestSupport",
            ]
        ),
        .testTarget(
            name: "FluxorMacrosTests",
            dependencies: [
                "FluxorMacrosImplementation",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
