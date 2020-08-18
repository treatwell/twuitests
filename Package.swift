// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TWUITests",
    platforms: [.iOS(.v9), .macOS(.v10_14)],
    products: [
        .library(name: "TWUITests", targets: ["TWUITests"])
    ],
    dependencies: [
        .package(name: "Swifter", url: "https://github.com/httpswift/swifter.git", .upToNextMajor(from: "1.4.7"))
    ],
    targets: [
        .target(
            name: "TWUITests",
            dependencies: ["Swifter"]
        ),
        .testTarget(
            name: "TWUITestsTests",
            dependencies: ["TWUITests"]
        )
    ]
)
