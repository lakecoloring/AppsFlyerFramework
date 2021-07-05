// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppsFlyerLib",
    products: [
        .library(name: "AppsFlyerLib", targets: ["AppsFlyerLib-Strict"]),
    ],
    dependencies: [
    ],
    targets: [
        .binaryTarget(name: "AppsFlyerLib-Strict", path: "Strict/AppsFlyerLib.xcframework"),
    ]
)
