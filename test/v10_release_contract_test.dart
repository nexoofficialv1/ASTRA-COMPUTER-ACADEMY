import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('v1 Android release-build contract is present', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(
      RegExp(r'^version:\s+\d+\.\d+\.\d+\+\d+\s*$', multiLine: true)
          .hasMatch(pubspec),
      isTrue,
      reason: 'pubspec.yaml must contain a semantic Flutter build version',
    );

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
    expect(bootstrap, contains('rm -f test/widget_test.dart'));

    final branding =
        File('scripts/apply_android_branding.py').readAsStringSync();
    expect(
      branding,
      contains("escaped_namespace = '`in`.nexoofficial.astra_computer_academy'"),
    );
    expect(
      branding,
      contains("g = g.replace(escaped_namespace, expected)"),
    );

    final workflow = File('.github/workflows/android-apk.yml').readAsStringSync();
    expect(workflow, contains('flutter analyze --no-fatal-infos'));
    expect(workflow, contains('flutter test'));
    expect(workflow, contains('flutter build apk --release'));
  });

  test('ASTRA Android overlay keeps the release permission surface offline-first', () {
    const textExtensions = <String>{
      '.xml',
      '.gradle',
      '.kts',
      '.properties',
      '.txt',
      '.json',
      '.yaml',
      '.yml',
    };

    final overlayText = Directory('tool/android_overlay')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => textExtensions.contains(_extension(file.path)))
        .map((file) => file.readAsStringSync())
        .join('\n');

    expect(overlayText, isNot(contains('android.permission.INTERNET')));
    expect(overlayText, isNot(contains('READ_EXTERNAL_STORAGE')));
    expect(overlayText, isNot(contains('WRITE_EXTERNAL_STORAGE')));
    expect(overlayText, isNot(contains('android.permission.CAMERA')));
    expect(overlayText, isNot(contains('android.permission.RECORD_AUDIO')));
  });
}

String _extension(String path) {
  final name = path.replaceAll('\\', '/').split('/').last;
  final dot = name.lastIndexOf('.');
  return dot == -1 ? '' : name.substring(dot).toLowerCase();
}
