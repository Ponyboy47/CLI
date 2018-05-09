// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "CLI",
    products: [
        .library(
            name: "CLI",
            targets: ["CLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Ponyboy47/Strings.git", .upToNextMajor(from: "2.2.0"))
    ],
    targets: [
        .target(
            name: "CLI",
            dependencies: ["Strings"]),
    ]
)
