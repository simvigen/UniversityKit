// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PersistenceKit",
    platforms: [
        .iOS("15.1")
    ],
    products: [
        .library(name: "PersistenceKit", targets: ["PersistenceKit"])
    ],
    dependencies: [
        .package(path: "../DomainKit"),
        .package(path: "../NetworkKit")
    ],
    targets: [
        .target(
            name: "PersistenceKit",
            dependencies: ["DomainKit", "NetworkKit"]
        ),
        .testTarget(
            name: "PersistenceKitTests",
            dependencies: ["PersistenceKit"]
        )
    ]
)
