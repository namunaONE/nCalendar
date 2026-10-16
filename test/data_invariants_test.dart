import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Invariant checker for the data commons (Linear HYA-347 groundwork;
/// the era-aware sankranti-window check of HYA-358 still needs the
/// Commons Layer 1 sankranti moments and will be added on top).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final lines = File('data/calendar.csv').readAsLinesSync();
  final rows = <List<String>>[
    for (final line in lines.skip(1))
      if (line.trim().isNotEmpty) line.split(','),
  ];

  DateTime parseIso(String iso) {
    final parts = iso.split('-').map(int.parse).toList();
    return DateTime.utc(parts[0], parts[1], parts[2]);
  }

  group('data/calendar.csv invariants', () {
    test('header', () {
      expect(lines.first,
          'bs_year,baisakh1_ad,m01,m02,m03,m04,m05,m06,m07,m08,m09,m10,m11,m12,evidence,sources,notes');
    });

    test('109 contiguous years, 1975..2083', () {
      expect(rows.length, 109);
      for (var i = 0; i < rows.length; i++) {
        expect(int.parse(rows[i][0]), 1975 + i);
      }
    });

    test('month lengths are 29..32; year totals 364..367', () {
      for (final row in rows) {
        final lengths = row.sublist(2, 14).map(int.parse).toList();
        for (final length in lengths) {
          expect(length >= 29 && length <= 32, true,
              reason: 'Month length out of range in year ${row[0]}');
        }
        final total = lengths.fold(0, (a, b) => a + b);
        expect(total >= 364 && total <= 367, true,
            reason: 'Implausible year length in year ${row[0]}: $total');
      }
    });

    test('chain closure: Baisakh 1 of year N+1 = Baisakh 1 of N + days(N)', () {
      for (var i = 0; i + 1 < rows.length; i++) {
        final total = rows[i]
            .sublist(2, 14)
            .map(int.parse)
            .fold(0, (a, b) => a + b);
        final expected = parseIso(rows[i][1])
            .add(Duration(days: total));
        expect(parseIso(rows[i + 1][1]), expected,
            reason: 'Chain broken between ${rows[i][0]} and ${rows[i + 1][0]}');
      }
    });

    test('evidence classes are valid and never empty', () {
      const allowed = {'verified', 'consensus', 'disputed', 'projection'};
      for (final row in rows) {
        expect(allowed.contains(row[14]), true,
            reason: 'Bad evidence class in year ${row[0]}: ${row[14]}');
      }
    });
  });

  group('assets/bs_data.json sync (codegen drift guard)', () {
    test('asset is the parsed-equal output of the CSV', () async {
      final asset =
          jsonDecode(await rootBundle.loadString('assets/bs_data.json'))
              as Map<String, dynamic>;
      expect(asset['schema'], 2);
      final years = (asset['years'] as List).cast<Map<String, dynamic>>();
      expect(years.length, rows.length);
      for (var i = 0; i < rows.length; i++) {
        expect(years[i]['bsYear'], int.parse(rows[i][0]));
        expect(years[i]['baisakh1Ad'], rows[i][1]);
        expect((years[i]['monthLengths'] as List).cast<int>(),
            rows[i].sublist(2, 14).map(int.parse).toList());
        expect(years[i]['evidence'], rows[i][14]);
        expect(years[i]['sources'], rows[i][15]);
        expect(years[i]['notes'], rows[i][16]);
      }
    });
  });
}
