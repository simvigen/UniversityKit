// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DomainKit",
    platforms: [
        .iOS("15.1")
    ],
    products: [
        .library(name: "DomainKit", targets: ["DomainKit"])
    ],
    targets: [
        .target(name: "DomainKit"),
        .testTarget(name: "DomainKitTests", dependencies: ["DomainKit"])
    ]
)
