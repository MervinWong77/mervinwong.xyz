// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SmokeRunner",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(path: "../../Packages/CopyCatEngine")
    ],
    targets: [
        .executableTarget(
            name: "SmokeRunner",
            dependencies: [
                .product(name: "CopyCatEngine", package: "CopyCatEngine")
            ]
        )
    ]
)
