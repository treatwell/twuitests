// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TWUITests",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "TWUITests",
            targets: ["TWUITests"]
        )
    ],
    dependencies: [
        .package(name: "Swifter", url: "https://github.com/httpswift/swifter.git", from: "1.5.0")
    ],
    targets: [
        .target(
            name: "TWUITests",
            dependencies: ["Swifter"],
            path: "TWUITests"
        ),
        .testTarget(
            name: "TWUITestsTests",
            dependencies: ["TWUITests"],
            path: "TWUITestsTests"
        )
    ]
)
