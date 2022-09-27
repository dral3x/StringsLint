// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StringsLint",
    products: [
        .executable(name: "stringslint", targets: ["stringslint"]),
        .library(name: "StringsLintFramework", targets: ["StringsLintFramework"])
    ],
    dependencies: [
        .package(url: "https://github.com/Carthage/Commandant.git", from: "0.15.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.1"),
    ],
    targets: [
        .target(
            name: "stringslint",
            dependencies: [
                "Commandant",
                "StringsLintFramework",
            ]),
        .target(
            name: "StringsLintFramework",
            dependencies: [
                "Yams",
            ]),
        .testTarget(
            name: "StringsLintFrameworkTests",
            dependencies: [
                "StringsLintFramework"
            ]
        )
    ]
)
