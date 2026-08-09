#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

./scripts/bootstrap_android.sh
flutter pub get
flutter analyze --no-fatal-infos
flutter test
flutter build apk --release

OUT="dist"
mkdir -p "$OUT"
cp build/app/outputs/flutter-apk/app-release.apk "$OUT/ASTRA_COMPUTER_ACADEMY_v1.0.0.apk"
echo "APK: $ROOT/$OUT/ASTRA_COMPUTER_ACADEMY_v1.0.0.apk"
