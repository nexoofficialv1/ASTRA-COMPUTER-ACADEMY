# ASTRA Computer Academy — Android APK Build Guide

## Recommended: GitHub Actions
1. Push this project to a GitHub repository.
2. Open **Actions** -> **Build Android APK**.
3. Choose **Run workflow**, or push to `main`.
4. The workflow creates a Flutter-compatible Android scaffold, applies ASTRA branding, runs analysis/tests, builds the release APK and uploads it as an Actions artifact.
5. Download artifact `ASTRA-COMPUTER-ACADEMY-v1.0.0-APK`.

Expected APK inside the artifact:
`ASTRA_COMPUTER_ACADEMY_v1.0.0.apk`

## Local machine with Flutter installed
```bash
chmod +x scripts/bootstrap_android.sh scripts/build_android_release.sh
./scripts/build_android_release.sh
```

Output:
`dist/ASTRA_COMPUTER_ACADEMY_v1.0.0.apk`

## Why Android is generated at build time
Flutter's Android Gradle template changes over time. `scripts/bootstrap_android.sh` asks the Flutter SDK used for that build to generate its own compatible Android scaffold, then applies only ASTRA-specific overlay resources and manifest hardening. This avoids pinning an old AGP/Kotlin/Gradle template in the application source.

## Package identity
- Project: `astra_computer_academy`
- Android application ID: `in.nexoofficial.astra_computer_academy`
- App label: `ASTRA Computer Academy`

## Offline permission policy
The production/main ASTRA manifest does not add INTERNET, broad external-storage, camera, microphone, location or contacts permissions. Course content, SQLite progress and practical labs are local. Debug/profile Flutter manifests created by the Flutter tool can differ for development purposes.

## Signing
The first APK is for direct device testing. Before Play Store publication, configure a private upload keystore and release signing. Never commit a `.jks`, `.keystore`, `key.properties`, passwords or private keys to Git.
