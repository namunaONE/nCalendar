/// One evidence-tagged BS year row from the nCalander data commons
/// (data/calendar.csv, mirrored into assets/bs_data.json schema 2).
///
/// This is the compact wire format: Baisakh 1 AD anchor plus twelve
/// month lengths. The full month/day grid is expanded at runtime by
/// BsCalendarEngine, so the shipped asset stays tiny.
class BsYearRow {
  final int bsYear;
  final String baisakh1Ad; // ISO yyyy-MM-dd (Nepal civil date, NPT)
  final List<int> monthLengths; // 12 entries: m01..m12
  final String evidence; // verified | consensus | disputed | projection
  final String sources;
  final String notes;

  const BsYearRow({
    required this.bsYear,
    required this.baisakh1Ad,
    required this.monthLengths,
    this.evidence = '',
    this.sources = '',
    this.notes = '',
  });

  factory BsYearRow.fromJson(Map<String, dynamic> json) => BsYearRow(
        bsYear: json['bsYear'] as int,
        baisakh1Ad: json['baisakh1Ad'] as String,
        monthLengths: (json['monthLengths'] as List)
            .map((e) => e as int)
            .toList(),
        evidence: json['evidence'] as String? ?? '',
        sources: json['sources'] as String? ?? '',
        notes: json['notes'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'bsYear': bsYear,
        'baisakh1Ad': baisakh1Ad,
        'monthLengths': monthLengths,
        'evidence': evidence,
        'sources': sources,
        'notes': notes,
      };

  @override
  String toString() => 'BsYearRow $bsYear ($baisakh1Ad, $evidence)';
}
