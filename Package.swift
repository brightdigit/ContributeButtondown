// swift-tools-version:6.4
// swiftlint:disable explicit_acl explicit_top_level_acl

import PackageDescription

let package = Package(
  name: "ContributeButtondown",
  // Matches the root package floor (raised to .v15 for issue #44); the vendored
  // Publish stack also requires macOS 15 (Synchronization.Mutex).
  platforms: [.macOS(.v15)],
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
