// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Pagination",
    products: [
        .library(name: "Pagination", targets: ["Pagination"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "3.0.0-rc"),
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0-rc")
    ],
    targets: [
        .target(name: "Pagination", dependencies: ["Vapor", "Fluent"]),
        .testTarget(name: "PaginationTests", dependencies: ["Pagination", "FluentSQLite"]),
    ]
)
