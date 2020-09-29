// swift-tools-version:5.3
import PackageDescription
let package = Package(
  name: "OpenCombineJS",
  products: [
    .executable(name: "OpenCombineJSExample", targets: ["OpenCombineJSExample"]),
    .library(name: "OpenCombineJS", targets: ["OpenCombineJS"]),
  ],
  dependencies: [
    .package(
      name: "JavaScriptKit",
      url: "https://github.com/swiftwasm/JavaScriptKit.git",
      from: "0.7.2"
    ),
    .package(
      name: "OpenCombine",
      url: "https://github.com/MaxDesiatov/OpenCombine.git",
      from: "0.0.1"
    ),
  ],
  targets: [
    .target(
      name: "OpenCombineJSExample",
      dependencies: [
        "OpenCombineJS",
      ]
    ),
    .target(
      name: "OpenCombineJS",
      dependencies: [
        "JavaScriptKit", "OpenCombine",
      ]
    ),
  ]
)
