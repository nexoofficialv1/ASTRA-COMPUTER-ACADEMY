#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter SDK not found in PATH." >&2
  exit 127
fi

# flutter create supplies the Android Gradle/AGP/Kotlin versions compatible with the
# Flutter SDK used for this build, rather than freezing stale platform boilerplate.
flutter create \
  --platforms=android \
  --org in.nexoofficial \
  --project-name astra_computer_academy \
  .

# flutter create adds the template MyApp smoke test when it is absent.
# ASTRA has its own app class and test suite, so remove that generated-only test.
rm -f test/widget_test.dart

python3 scripts/apply_android_branding.py

echo "Android scaffold ready: in.nexoofficial.astra_computer_academy"
