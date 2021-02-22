// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SourceCode",
    platforms: [
        .iOS(.v13),
        .macOS(.v11),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "SourceCode",
            targets: ["SourceCode"]
        )
    ],
    dependencies: [
        .package(path: "../SimulatorKit"),
        .package(url: "https://github.com/vmanot/Swallow.git", .branch("master")),
        .package(url: "https://github.com/SwiftDocOrg/SwiftMarkup.git", from: "0.2.1"),
        .package(url: "https://github.com/SwiftDocOrg/SwiftSemantics.git", from: "0.2.0"),
        .package(
            name: "SwiftSyntax",
            url: "https://github.com/apple/swift-syntax.git",
            from: "0.50300.0"
        ),
        .package(url: "https://github.com/NSHipster/SwiftSyntaxHighlighter", .branch("master")),
    ],
    targets: [
        .target(
            name: "SourceCode",
            dependencies: [
                "SimulatorKit",
                "Swallow",
                "SwiftMarkup",
                "SwiftSemantics",
                "SwiftSyntax",
                "SwiftSyntaxHighlighter",
            ],
            path: "Sources"
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