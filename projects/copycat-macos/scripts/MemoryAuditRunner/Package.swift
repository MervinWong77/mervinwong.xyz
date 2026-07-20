// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MemoryAuditRunner",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(path: "../../Packages/CopyCatEngine")
    ],
    targets: [
        .executableTarget(
            name: "MemoryAuditRunner",
            dependencies: [
                .product(name: "CopyCatEngine", package: "CopyCatEngine")
            ]
        )
    ]
)
