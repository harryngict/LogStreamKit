// swift-tools-version:6.0
import PackageDescription

let package = Package(
  name: "LogStreamKit",
  platforms: [.iOS(.v15)],
  products: [
    // LogStreamKit, LogStreamKitImp, LogStreamKitMock
    .library(
      name: "LogStreamKit",
      targets: ["LogStreamKit"]
    ),
    .library(
      name: "LogStreamKitImp",
      targets: ["LogStreamKitImp"]
    ),
    .library(
      name: "LogStreamKitMock",
      targets: ["LogStreamKitMock"]
    ),
  ],
  dependencies: [
  ],
  targets: [
    // LogStreamKit, LogStreamKitImp, LogStreamKitMock
    .target(
      name: "LogStreamKit",
      dependencies: [],
      path: "Sources/LogStreamKit/interfaces/src"
    ),
    .target(
      name: "LogStreamKitImp",
      dependencies: [
        "LogStreamKit",
      ],
      path: "Sources/LogStreamKit/implementation/src"
    ),
    .target(
      name: "LogStreamKitMock",
      dependencies: ["LogStreamKit"],
      path: "Sources/LogStreamKit/mocks/src"
    ),
  ],
  swiftLanguageModes: [.v6]
)
