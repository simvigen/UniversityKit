// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CommonUI",
    platforms: [
        .iOS("15.1")
    ],
    products: [
        .library(name: "CommonUI", targets: ["CommonUI"])
    ],
    targets: [
        .target(name: "CommonUI")
    ]
)
