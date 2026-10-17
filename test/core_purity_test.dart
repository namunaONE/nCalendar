import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Purity guard (C2a HYA-375, repointed in C2b): the nbs package
/// (packages/nbs) is pure Dart — it must never import package:flutter
/// or dart:ui. This test fails the build if that boundary is crossed.
void main() {
  test('the nbs package stays pure Dart (no package:flutter / dart:ui imports)', () {
    final nbsDir = Directory('packages/nbs/lib');
    expect(nbsDir.existsSync(), isTrue,
        reason: 'packages/nbs/lib directory must exist');

    final dartFiles = nbsDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList();
    expect(dartFiles, isNotEmpty,
        reason: 'packages/nbs/lib must contain the core files');

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
            'packages/nbs/lib must stay pure Dart. Offending files: ${offenders.join(', ')}');
  });
}
