// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NotchFish",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "NotchFish",
            path: "NotchFish",
            exclude: ["App/Info.plist"],
            linkerSettings: [
                .linkedFramework("Cocoa"),
                .linkedFramework("SpriteKit"),
            ]
        ),
    ]
)
