// swift-tools-version: 5.7

import PackageDescription

let package: Package = Package(
  name: "SwiftGame",
  dependencies: [
    .package(url: "https://github.com/AdamEisfeld/PhyKit.git", branch: "master"),
    .package(url: "https://github.com/STREGAsGate/Raylib.git", branch: "master"),
	// .package(url: "https://github.com/STREGAsGate/GameMath.git", .revision("d540badd052c61c9917a54edb5dcb1dc4741c01c")),
    .package(url: "https://github.com/SwifterSwift/SwifterSwift.git", branch: "master"),
  ],
  targets: [
    .executableTarget(
      name: "SwiftGame",
      dependencies: ["PhyKit", "Raylib", "SwifterSwift"],
      resources: [.process("Resources")]
    )
  ]
)
