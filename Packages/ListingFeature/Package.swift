// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ListingFeature",
    platforms: [
        .iOS("15.1")
    ],
    products: [
        .library(name: "ListingFeature", targets: ["ListingFeature"])
    ],
    dependencies: [
        .package(path: "../DomainKit"),
        .package(path: "../CommonUI")
    ],
    targets: [
        .target(
            name: "ListingFeature",
            dependencies: ["DomainKit", "CommonUI"]
        ),
        .testTarget(
            name: "ListingFeatureTests",
            dependencies: ["ListingFeature"]
        )
    ]
)
