# ASTRA Computer Academy — v1.0.0 Android Build-Ready Source

Offline-first Flutter learning app for Bengali learners, built around **Theory -> Practice -> Assessment -> Mastery -> Certification**.

## Basic Computer release coverage
- 9 course areas
- 60 bundled offline lessons
- 40 interactive practical lessons
- Computer Fundamentals
- MS Word editor/evaluator, office documents, page setup, save/print, Header/Footer/Page Number
- MS Excel grid/formula engine: arithmetic, SUM, AVERAGE, MIN, MAX, COUNT, IF, COUNTIF, SUMIF, exact-match VLOOKUP, Percentage, Sort/Filter, Chart and Print Setup practice
- Data Entry accuracy/speed scoring
- English/Bengali Typing WPM/accuracy scoring
- Windows File Manager, keyboard shortcuts and Desktop/Taskbar simulator
- Internet Browser/search/download/upload sandbox and Email compose/attachment simulator
- MS PowerPoint slide simulator
- Integrated office project assignment
- SQLite progress, practical attempts, streak, final exam and certificate records
- Offline JSON Backup/Restore
- Certificate text, HTML and printable PDF export

## v1.0.0 release hardening
- Version `1.0.0+10`
- Reproducible Android scaffold bootstrap using the installed Flutter SDK
- ASTRA launcher icon and native Android splash resources
- App label `ASTRA Computer Academy`
- Android app ID `in.nexoofficial.astra_computer_academy`
- Cleartext traffic disabled and Android system backup disabled in the main app manifest
- No ASTRA release INTERNET/storage/location/camera/microphone/contact permission added
- Small-screen dashboard adaptations for narrow phones
- GitHub Actions pipeline for `flutter analyze`, `flutter test` and release APK build
- Local one-command Android build script
- APK checksum generation

## Build with GitHub Actions
Push this repository to GitHub, open **Actions -> Build Android APK -> Run workflow**. The workflow creates the Android scaffold compatible with the pinned Flutter 3.44.7 stable SDK, applies ASTRA branding, validates the Dart/Flutter source and builds the APK.

Expected artifact:
`ASTRA-COMPUTER-ACADEMY-v1.0.1-APK`

## Build locally
With Flutter and Android tooling installed:

```bash
chmod +x scripts/bootstrap_android.sh scripts/build_android_release.sh
./scripts/build_android_release.sh
```

Expected file:
`dist/ASTRA_COMPUTER_ACADEMY_v1.0.1.apk`

See `ANDROID_BUILD_GUIDE.md` for details.

## Certification policy
A learner can issue the offline Foundation Certificate only after:
1. Student Profile is complete.
2. All current lessons are completed.
3. Final Practical Exam is passed.
4. Every final-exam component scores at least 60%.
5. Final average is at least 70%.

## Validation boundary
The packaging environment used to assemble this source does not contain Flutter/Dart SDK, therefore the included report is a **source/build-contract validation**, not a claim that the APK has already compiled. The GitHub Actions run is the real compile/test gate. After the first successful APK build, install it on at least one small phone and one normal-size phone and complete the onboarding, a theory lesson, quiz, Word lab, Excel lab, Data Entry/Typing lab, final-exam navigation, backup and PDF certificate paths before calling it production-ready.

## Release signing
The first build is intended for direct device testing. Before Play Store publication, configure a private upload keystore and release signing. Do not commit keystores or passwords.
