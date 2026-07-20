// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CopyCatEngine",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "CopyCatEngine",
            targets: ["CopyCatEngine"]
        )
    ],
    targets: [
        .target(
            name: "CopyCatEngine",
            path: "Sources/CopyCatEngine",
            linkerSettings: [
                .linkedLibrary("sqlite3")
            ]
        ),
        .testTarget(
            name: "CopyCatEngineTests",
            dependencies: ["CopyCatEngine"],
            path: "Tests/CopyCatEngineTests"
        )
    ]
)
