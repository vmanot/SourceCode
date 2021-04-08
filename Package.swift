// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SourceCode",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "SourceCode",
            targets: ["SourceCode"]
        )
    ],
    dependencies: [
        .package(name: "SwiftSyntax", url: "https://github.com/apple/swift-syntax.git", .revision("0.50300.0")),
        .package(url: "https://github.com/SwiftDocOrg/swift-doc", .branch("master")),
        .package(url: "https://github.com/SwiftDocOrg/SwiftSemantics.git", .upToNextMinor(from: "0.1.0")),
        .package(url: "https://github.com/SwiftUIX/SwiftUIX.git", .branch("master")),
        .package(url: "https://github.com/vmanot/Swallow.git", .branch("master")),
        .package(url: "https://github.com/vmanot/SimulatorKit.git", .branch("master")),
    ],
    targets: [
        .target(
            name: "SourceCode",
            dependencies: [
                "SimulatorKit",
                "Swallow",
                .product(name: "SwiftDoc", package: "swift-doc", condition: .when(platforms: [.macOS])),
                .byName(name: "SwiftSyntax", condition: .when(platforms: [.macOS])),
                .byName(name: "SwiftSemantics", condition: .when(platforms: [.macOS])),
                "SwiftUIX",
            ],
            path: "Sources",
            resources: [
                .copy("Resources/ace.bundle")
            ]
        ),
        .testTarget(
            name: "SourceCodeTests",
            dependencies: [
                "SourceCode"
            ],
            path: "Tests"
        )
    ]
)
