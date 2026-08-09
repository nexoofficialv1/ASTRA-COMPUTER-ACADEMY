#!/usr/bin/env python3
from pathlib import Path
import re, shutil, sys

root = Path(__file__).resolve().parents[1]
android = root / 'android'
manifest = android / 'app/src/main/AndroidManifest.xml'
if not manifest.exists():
    raise SystemExit('Android scaffold is missing. Run scripts/bootstrap_android.sh first.')

text = manifest.read_text(encoding='utf-8')
# Replace whatever flutter create used as the launcher label.
text, count = re.subn(r'android:label="[^"]*"', 'android:label="ASTRA Computer Academy"', text, count=1)
if count != 1:
    raise SystemExit('Could not locate android:label in AndroidManifest.xml')
# Harden release manifest without requesting network/storage permissions.
if 'android:usesCleartextTraffic=' not in text:
    text = text.replace('<application\n', '<application\n        android:usesCleartextTraffic="false"\n', 1)
if 'android:allowBackup=' not in text:
    text = text.replace('<application\n', '<application\n        android:allowBackup="false"\n', 1)
manifest.write_text(text, encoding='utf-8')

overlay = root / 'tool/android_overlay/res'
res = android / 'app/src/main/res'
for source in overlay.rglob('*'):
    if source.is_dir():
        continue
    target = res / source.relative_to(overlay)
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, target)

# Validate expected app id generated from --org + project name.
gradle_kts = android / 'app/build.gradle.kts'
gradle_groovy = android / 'app/build.gradle'
gradle = gradle_kts if gradle_kts.exists() else gradle_groovy
if not gradle.exists():
    raise SystemExit('Generated Android app Gradle file not found.')
g = gradle.read_text(encoding='utf-8')
expected = 'in.nexoofficial.astra_computer_academy'
if expected not in g:
    print(f'WARNING: expected application id {expected} was not found in {gradle.name}', file=sys.stderr)

print('ASTRA Android branding/hardening applied.')
