// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package: Package = Package(
    name: "SwiftGame",
    dependencies: [
        .package(url: "https://github.com/AdamEisfeld/PhyKit.git", from: "1.0.1"),
        .package(url: "https://github.com/STREGAsGate/Raylib.git", branch: "master"),

        // change branch to master after PR goes thru
        .package(url: "https://github.com/SwifterSwift/SwifterSwift.git", branch: "HKActivitySummary-macos")
    ],
    targets: [
        .executableTarget(
            name: "SwiftGame",
            dependencies: ["PhyKit", "Raylib", "SwifterSwift"]
            ),
    ]
)
