// swift-tools-version: 5.7

import PackageDescription

let package: Package = Package(
    name: "SwiftGame",
    dependencies: [
        .package(url: "https://github.com/AdamEisfeld/PhyKit.git", revision: "43a76569fc740f6b241b238292131538f30beb80"),
        .package(url: "https://github.com/STREGAsGate/Raylib.git", revision: "9e7c83604f74211e4f8f3c38c1c52d4434f51bc1"),
        .package(url: "https://github.com/SwifterSwift/SwifterSwift.git", revision: "08e7674634d93c207059cc69748898ef24caa8d4"),
    ],
    targets: [
        .executableTarget(
            name: "SwiftGame",
            dependencies: ["PhyKit", "Raylib", "SwifterSwift"],
            resources: [.process("Resources")]
        )
    ]
)
