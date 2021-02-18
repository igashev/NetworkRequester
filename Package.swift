// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "NetworkRequester",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
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
