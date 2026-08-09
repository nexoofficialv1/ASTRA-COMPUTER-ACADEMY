import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('v1.0 Android release-build contract is present', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('version: 1.0.0+10'));

    for (final path in <String>[
      'scripts/bootstrap_android.sh',
      'scripts/apply_android_branding.py',
      'scripts/build_android_release.sh',
      '.github/workflows/android-apk.yml',
      'assets/branding/app_icon_1024.png',
      'tool/android_overlay/res/values/styles.xml',
      'tool/android_overlay/res/values-v31/styles.xml',
    ]) {
      expect(File(path).existsSync(), isTrue, reason: '$path must exist');
    }

    final bootstrap = File('scripts/bootstrap_android.sh').readAsStringSync();
    expect(bootstrap, contains('flutter create'));
    expect(bootstrap, contains('--platforms=android'));
    expect(bootstrap, contains('--org in.nexoofficial'));

    final workflow = File('.github/workflows/android-apk.yml').readAsStringSync();
    expect(workflow, contains('flutter analyze --no-fatal-infos'));
    expect(workflow, contains('flutter test'));
    expect(workflow, contains('flutter build apk --release'));
  });

  test('ASTRA Android overlay keeps the release permission surface offline-first', () {
    final overlay = Directory('tool/android_overlay')
        .listSync(recursive: true)
        .whereType<File>()
        .map((file) => file.readAsStringSync())
        .join('\n');

    expect(overlay, isNot(contains('android.permission.INTERNET')));
    expect(overlay, isNot(contains('READ_EXTERNAL_STORAGE')));
    expect(overlay, isNot(contains('WRITE_EXTERNAL_STORAGE')));
    expect(overlay, isNot(contains('android.permission.CAMERA')));
    expect(overlay, isNot(contains('android.permission.RECORD_AUDIO')));
  });
}
