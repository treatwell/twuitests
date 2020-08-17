// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TWUITests",
    platforms: [.iOS(.v9), .macOS(.v10_15)],
    products: [
        .library(name: "TWUITests", targets: ["TWUITests"]),
//        .executable(name: "Example", targets: ["Example"])
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
        ),
//        .target(
//            name: "TWExample",
//            dependencies: ["TWUITests"],
//            path: "Example"
//        ),
//        .testTarget(
//            name: "ExampleUITests",
//            dependencies: ["Swifter"],
//            path: "ExampleUITests"
//        )
    ]
)
