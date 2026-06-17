// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WWMarkdownWebViewUI",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "WWMarkdownWebViewUI", targets: ["WWMarkdownWebViewUI"]),
    ],
    targets: [
        .target(name: "WWMarkdownWebViewUI", resources: [.process("Resources"), .copy("Privacy")]),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
