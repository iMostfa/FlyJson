// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "FlyJson",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/jpsim/SourceKitten.git", .upToNextMinor(from: "0.21.2")),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0-rc"),
        .package(url: "https://github.com/grpc/grpc-swift.git", .exact("1.0.0-alpha.17")),
        .package(url: "https://github.com/vapor/fluent-mongo-driver.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/iMostfa/vapor.git", .branch("master")),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0")
        
        
        
    ],
    targets: [
        .target(
            name: "App",
            dependencies:[
                .product(name: "SourceKittenFramework", package: "SourceKitten"),
                .product(name: "Leaf", package: "leaf"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentMongoDriver", package: "fluent-mongo-driver"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver")
],
            
            swiftSettings: [
                // Enable better optimizations when building in Release configuration. Despite the use of
                // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
                // builds. See <https://github.com/swift-server/guides#building-for-production> for details.
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .target(name: "Run", dependencies: [.target(name: "App")]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
