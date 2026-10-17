import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// C2a purity guard (Linear HYA-375, R10 architecture round).
/// lib/core is the seed of the future pure-Dart nbs package: it must
/// never import package:flutter or dart:ui. This test fails the build
/// if that boundary is ever crossed.
void main() {
  test('lib/core stays pure Dart (no package:flutter / dart:ui imports)', () {
    final coreDir = Directory('lib/core');
    expect(coreDir.existsSync(), isTrue,
        reason: 'lib/core directory must exist');

    final dartFiles = coreDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList();
    expect(dartFiles, isNotEmpty,
        reason: 'lib/core must contain the extracted core files');

    final forbidden = RegExp(
        r"""(?:import|export)\s+['"][^'"]*(?:package:flutter|dart:ui)[^'"]*['"]""");

    final offenders = <String>[];
    for (final file in dartFiles) {
      if (forbidden.hasMatch(file.readAsStringSync())) {
        offenders.add(file.path);
      }
    }

    expect(offenders, isEmpty,
        reason:
            'lib/core must stay pure Dart. Offending files: ${offenders.join(', ')}');
  });
}
