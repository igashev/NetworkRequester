// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "NetworkRequester",
    platforms: [
        .iOS(.v13),
        .macOS(.v12),
        .tvOS(.v13),
    ],
    products: [
        .library(
            name: "NetworkRequester",
            targets: ["NetworkRequester"]),
    ],
    targets: [
        .target(
            name: "NetworkRequester",
            dependencies: []),
        .testTarget(
            name: "NetworkRequesterTests",
            dependencies: ["NetworkRequester"]),
    ],
    swiftLanguageVersions: [.v5]
)
