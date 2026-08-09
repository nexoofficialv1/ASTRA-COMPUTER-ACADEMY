# v1.0.0 Android APK Build-Ready Hardening

## Goal
Turn the Basic Computer Release Candidate into a reproducible Android APK build package without freezing stale Gradle/AGP/Kotlin boilerplate.

## Implemented
- Version `1.0.0+10`.
- Reproducible Android scaffold bootstrap via `flutter create --platforms=android`.
- Android application ID generated as `in.nexoofficial.astra_computer_academy`.
- Display name: **ASTRA Computer Academy**.
- ASTRA launcher icon assets for mdpi through xxxhdpi.
- Native ASTRA launch screen resources for pre-Android-12 and Android-12+.
- Release manifest hardening: cleartext traffic disabled, Android system backup disabled, no release INTERNET or storage permission added by ASTRA.
- GitHub Actions Android build pipeline: doctor -> scaffold -> pub get -> analyze -> tests -> release APK -> checksum -> artifact upload.
- Local build script using the same validation gates.
- Small-screen dashboard hardening for narrow phones.
- Build/readiness documentation and source-level release checks.

## Important signing note
The generated Flutter template may use the debug signing configuration for an installable release build until a private release/upload key is configured. This v1.0 package is intended for device testing and course validation. Configure a private upload key before Play Store publication.

## Validation boundary
This packaging environment has no Flutter SDK/Dart SDK, so `flutter analyze`, `flutter test`, Gradle compilation, APK installation and device runtime tests could not be executed here. GitHub Actions is the first real compile gate.
