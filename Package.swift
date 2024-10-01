// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StringsLint",
    products: [
        .executable(name: "stringslint", targets: ["stringslint"]),
        .library(name: "StringsLintFramework", targets: ["StringsLintFramework"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", exact: "1.5.0"),
        .package(url: "https://github.com/jpsim/Yams.git", exact: "5.0.6"),
    ],
    targets: [
        .executableTarget(
            name: "stringslint",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "StringsLintFramework",
            ]),
        .target(
            name: "StringsLintFramework",
            dependencies: [
                .product(name: "Yams", package: "Yams"),
            ]),
        .testTarget(
            name: "StringsLintFrameworkTests",
            dependencies: [
                "StringsLintFramework"
            ]
        )
    ]
)
