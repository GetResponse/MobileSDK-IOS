// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GetResponseMobileSDK-IOS",
    platforms: [.iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "GetResponseMobileSDK-IOS",
            targets: ["GetResponseMobileSDK-IOS"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Kitura/Swift-JWT.git", from: "4.0.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "GetResponseMobileSDK-IOS", dependencies: [.product(name: "SwiftJWT", package: "swift-jwt")]),
        .testTarget(
            name: "GetResponseMobileSDK-IOSTests",
            dependencies: ["GetResponseMobileSDK-IOS"]),
    ]
)
