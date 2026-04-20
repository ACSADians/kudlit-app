
This guide explains how to set up, run, test, and build the Kudlit Flutter
application from a fresh checkout.

## Project Summary

Kudlit is a Flutter application for Baybayin recognition and translation. The
project currently includes platform targets for Android, iOS, Web, macOS,
Linux, and Windows.

The app package name is:

```text
kudlit_ph
```

The main entry point is:

```text
lib/main.dart
```

## Prerequisites

Install these before running the app:

- Flutter SDK with Dart support
- Android Studio for Android emulator or physical Android devices
- Xcode for iOS or macOS development on macOS
- Chrome for Web development
- Git

The project declares this Dart SDK constraint in `pubspec.yaml`:

```yaml
environment:
  sdk: ^3.11.5
```

After installing Flutter, verify your local setup:

```bash
flutter doctor
```

If `flutter` is not found, add the Flutter SDK `bin` directory to your PATH.

## First-Time Setup

From the repository root:

```bash
cd kudlit-app
flutter pub get
```

`flutter pub get` installs the dependencies from `pubspec.yaml` and resolves
them using `pubspec.lock`.

Current dependencies include:

- `flutter`
- `cupertino_icons`
- `ultralytics_yolo`
- `flutter_lints`
- `flutter_test`

## Check Available Devices

Run:

```bash
flutter devices
```

This lists connected phones, emulators, simulators, desktop targets, and Chrome
if Web support is available.

## Run The App

### Web

Use Chrome for the fastest local development loop:

```bash
flutter run -d chrome
```

### Android

Start an Android emulator or connect a physical Android device with USB
debugging enabled, then run:

```bash
flutter run -d android
```

If Flutter shows multiple Android devices, use the exact device ID from
`flutter devices`:

```bash
flutter run -d <device-id>
```

### iOS

Use an iOS simulator or connected iPhone:

```bash
flutter run -d ios
```

For physical iPhones, make sure Xcode signing is configured under the iOS
Runner target.

### macOS

On macOS:

```bash
flutter run -d macos
```

### Windows

On Windows:

```bash
flutter run -d windows
```

### Linux

On Linux:

```bash
flutter run -d linux
```

## Useful Development Commands

Install or refresh packages:

```bash
flutter pub get
```

Analyze Dart code:

```bash
flutter analyze
```

Run all tests:

```bash
flutter test
```

Run one test file:

```bash
flutter test test/widget_test.dart
```

Format source and tests:

```bash
dart format lib/ test/
```

## Build Commands

Build Web output:

```bash
flutter build web
```

Build Android APK:

```bash
flutter build apk --release
```

Build Android App Bundle:

```bash
flutter build appbundle --release
```

Build iOS release artifacts on macOS:

```bash
flutter build ios --release
```

Build macOS release app:

```bash
flutter build macos --release
```

## Recommended Local Workflow

1. Pull the latest changes.
2. Run `flutter pub get`.
3. Run `flutter analyze`.
4. Run `flutter test`.
5. Start the app with `flutter run -d chrome` or your target device.
6. Make code changes.
7. Re-run `flutter analyze` and `flutter test` before committing.

## Project Structure

```text
.
├── android/              Android platform project
├── ios/                  iOS platform project
├── lib/                  Flutter application source
│   └── main.dart         App entry point
├── linux/                Linux platform project
├── macos/                macOS platform project
├── test/                 Flutter tests
├── web/                  Web platform project
├── windows/              Windows platform project
├── analysis_options.yaml Dart analyzer and lint configuration
├── pubspec.lock          Locked dependency versions
└── pubspec.yaml          App metadata and dependency definitions
```

## Platform Notes

Web is useful for UI work, but camera and TFLite behavior may differ from
mobile platforms. Test scanner and ML features on Android or iOS when those
features are active.

The app uses `ultralytics_yolo`, so native platform setup may be required as
scanner functionality grows. If a platform build fails, check the plugin's
platform-specific requirements and run `flutter doctor`.

## Troubleshooting

### `flutter: command not found`

Flutter is either not installed or its `bin` directory is not on your PATH.
Install Flutter, then add this to your shell profile with your actual SDK path:

```bash
export PATH="$PATH:/path/to/flutter/bin"
```

Restart the terminal and run:

```bash
flutter --version
```

### Dependencies fail to install

Try:

```bash
flutter clean
flutter pub get
```

### No devices found

Check available devices:

```bash
flutter devices
```

For Android, start an emulator from Android Studio or connect a phone with USB
debugging enabled.

For iOS, open Simulator from Xcode or connect a trusted iPhone.

For Web, make sure Chrome is installed and Web support is enabled:

```bash
flutter config --enable-web
```

### Android build fails

Run:

```bash
flutter doctor --android-licenses
flutter doctor
```

Then accept any missing licenses and install missing Android SDK components from
Android Studio.

### iOS build fails

Run:

```bash
flutter doctor
open ios/Runner.xcworkspace
```

In Xcode, check signing, bundle identifier, team selection, and deployment
target.

## Before Opening A Pull Request

Run:

```bash
dart format lib/ test/
flutter analyze
flutter test
```

Only commit generated platform changes when they are intentional.
