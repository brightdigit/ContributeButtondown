// swift-tools-version:6.4
// swiftlint:disable explicit_acl explicit_top_level_acl

import PackageDescription

let package = Package(
  name: "ContributeButtondown",
  platforms: [.macOS(.v13)],
  products: [
    .library(
      name: "ContributeButtondown",
      targets: ["ContributeButtondown"]
    )
  ],
  dependencies: [
    .package(path: "../../BrightDigit/Contribute"),
    .package(path: "../../BrightDigit/ButtondownKit")
  ],
  targets: [
    .target(
      name: "ContributeButtondown",
      dependencies: [
        "Contribute",
        .product(name: "ButtondownKit", package: "ButtondownKit")
      ]
    ),
    .testTarget(
      name: "ContributeButtondownTests",
      dependencies: [
        "ContributeButtondown",
        "Contribute",
        .product(name: "ButtondownKit", package: "ButtondownKit")
      ]
    )
  ]
)
