import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Phase 8.2 full poster pack replaces every Class V visual', () {
    const assets = <String>[
      'computer_generations.png',
      'ipo_flow.png',
      'device_sorting.png',
      'hardware_software.png',
      'windows_desktop.png',
      'files_folders.png',
      'word_tools.png',
      'paint3d_tools.png',
      'scratch_interface.png',
      'scratch_quiz_flow.png',
      'internet_safety.png',
      'human_vs_ai.png',
    ];

    for (final name in assets) {
      final file = File('assets/visuals/class5/$name');
      expect(file.existsSync(), isTrue, reason: name);
      expect(file.lengthSync(), greaterThan(300000),
          reason: '$name must be a real high-detail learning poster');
    }

    final generations =
        File('assets/visuals/class5/computer_generations_visual_first.jpg');
    expect(generations.existsSync(), isTrue);
    expect(generations.lengthSync(), greaterThan(100000));
  });
}
