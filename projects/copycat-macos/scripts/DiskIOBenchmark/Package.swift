// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DiskIOBenchmark",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(path: "../../Packages/CopyCatEngine")
    ],
    targets: [
        .executableTarget(
            name: "DiskIOBenchmark",
            dependencies: ["CopyCatEngine"]
        )
    ]
)
