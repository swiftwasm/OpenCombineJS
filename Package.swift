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
      from: "0.10.0"
    ),
    .package(url: "https://github.com/TokamakUI/OpenCombine.git", from: "0.12.0-alpha3"),
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
