// swift-tools-version: 5.7

import PackageDescription

let package: Package = Package(
  name: "SwiftGame",
  dependencies: [
    .package(url: "https://github.com/AdamEisfeld/PhyKit.git", from: "1.0.1"),
    .package(url: "https://github.com/STREGAsGate/Raylib.git", branch: "master"),
    .package(url: "https://github.com/mezhevikin/Measure.git", from: "0.0.1"),

    // .package(url: "https://github.com/STREGAsGate/GameMath", branch: "master"),
    // change branch to master after PR goes thru
    .package(url: "https://github.com/SwifterSwift/SwifterSwift.git", branch: "HKActivitySummary-macos"),
  ],
  targets: [
    .executableTarget(
      name: "SwiftGame",
      dependencies: ["PhyKit", "Raylib", "SwifterSwift", "Measure"],
      resources: [.process("Resources")]
    )
  ]
)
