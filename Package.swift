// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "kituraRegistration",
    dependencies: [
      .package(url: "https://github.com/IBM-Swift/Kitura.git", from: "2.6.0"),
      .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", .upToNextMinor(from: "1.7.1")),
      .package(url: "https://github.com/IBM-Swift/CloudEnvironment.git", from: "6.0.0"),
      .package(url: "https://github.com/IBM-Swift/Configuration.git", from: "3.0.0"),
      .package(url: "https://github.com/IBM-Swift/Health.git", from: "0.0.0"),
      .package(url: "https://github.com/OpenKitten/MongoKitten.git", from: "4.0.0"),
      .package(url: "https://github.com/OpenKitten/Meow.git", from: "1.0.0"),
      .package(url: "https://github.com/RuntimeTools/SwiftMetrics.git", from: "2.0.0"),
      .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "4.0.0"),
    ],
    targets: [
      .target(name: "kituraRegistration", dependencies: [ .target(name: "Application"), "Kitura" , "HeliumLogger"]),
      .target(name: "Application", dependencies: [ "Kitura", "Configuration", "CloudEnvironment","Health","MongoKitten","Meow","SwiftMetrics", "SwiftyJSON"]),

      .testTarget(name: "ApplicationTests" , dependencies: [.target(name: "Application"), "Kitura","HeliumLogger" ])
    ]
)
