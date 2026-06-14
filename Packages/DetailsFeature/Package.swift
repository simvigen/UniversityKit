// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DetailsFeature",
    platforms: [
        .iOS("15.1")
    ],
    products: [
        .library(name: "DetailsFeature", targets: ["DetailsFeature"])
    ],
    dependencies: [
        .package(path: "../DomainKit"),
        .package(path: "../CommonUI")
    ],
    targets: [
        .target(
            name: "DetailsFeature",
            dependencies: ["DomainKit", "CommonUI"]
        ),
        .testTarget(
            name: "DetailsFeatureTests",
            dependencies: ["DetailsFeature"]
        )
    ]
)
