// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SuiSwift",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SuiSwift",
            targets: ["SuiSwift"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.6.1")),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "4.0.0"),
        .package(url: "https://github.com/skywinder/web3swift.git", .upToNextMajor(from: "3.2.1")),
        .package(url: "https://github.com/pebble8888/ed25519swift.git", from: "1.2.7"),
        .package(url: "https://github.com/tesseract-one/Blake2.swift.git", from: "0.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SuiSwift",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "web3swift", package: "web3swift"),
                .product(name: "SwiftyJSON", package: "SwiftyJSON"),
                .product(name: "ed25519swift", package: "ed25519swift"),
                .product(name: "Blake2", package: "Blake2.swift"),
            ]),
        .testTarget(
            name: "SuiSwiftTests",
            dependencies: ["SuiSwift"]),
    ]
)
