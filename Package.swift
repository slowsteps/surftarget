// swift-tools-version: 5.5

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "surftracker",
    platforms: [
        .iOS("15.2")
    ],
    products: [
        .iOSApplication(
            name: "surftracker",
            targets: ["AppModule"],
            bundleIdentifier: "wungi.tuto",
            teamIdentifier: "TW9F2F5PGW",
            displayVersion: "1.0",
            bundleVersion: "1",
            iconAssetName: "AppIcon",
            accentColorAssetName: "AccentColor",
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ],
            capabilities: [
                .locationWhenInUse(purposeString: "Surftracker needs to know where it is and where it's heading"),
                .bluetoothAlways(purposeString: "Surftracker needs bluetooth to connect to the motor")
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "."
        )
    ]
)