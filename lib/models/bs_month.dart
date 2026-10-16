import 'bs_day.dart';

/// A BS month (e.g. Baisakh 2083) with all of its day rows.
class BsMonth {
  final int bsYear;
  final int bsMonth; // 1 = Baisakh ... 12 = Chaitra
  final String bsMonthName;
  final String bsMonthNameNepali;
  final int daysInMonth;
  final String adStart; // ISO yyyy-MM-dd
  final String adEnd;   // ISO yyyy-MM-dd
  final List<BsDay> days;
  final String evidence; // verified | consensus | disputed | projection
  final String sources;
  final String notes;

  const BsMonth({
    required this.bsYear,
    required this.bsMonth,
    required this.bsMonthName,
    required this.bsMonthNameNepali,
    required this.daysInMonth,
    required this.adStart,
    required this.adEnd,
    required this.days,
    this.evidence = '',
    this.sources = '',
    this.notes = '',
  });

  factory BsMonth.fromJson(Map<String, dynamic> json) {
    final month = BsMonth(
      bsYear: json['bsYear'] as int,
      bsMonth: json['bsMonth'] as int,
      bsMonthName: json['bsMonthName'] as String,
      bsMonthNameNepali: json['bsMonthNameNepali'] as String,
      daysInMonth: json['daysInMonth'] as int,
      adStart: json['adStart'] as String,
      adEnd: json['adEnd'] as String,
      days: (json['days'] as List)
          .map((e) => BsDay.fromJson(e as Map<String, dynamic>))
          .toList(),
      evidence: json['evidence'] as String? ?? '',
      sources: json['sources'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
    );
    // Give each day its year/month context.
    for (final day in month.days) {
      day.setMonthContext(month.bsYear, month.bsMonth);
    }
    return month;
  }

  Map<String, dynamic> toJson() => {
        'bsYear': bsYear,
        'bsMonth': bsMonth,
        'bsMonthName': bsMonthName,
        'bsMonthNameNepali': bsMonthNameNepali,
        'daysInMonth': daysInMonth,
        'adStart': adStart,
        'adEnd': adEnd,
        'days': days.map((d) => d.toJson()).toList(),
        'evidence': evidence,
        'sources': sources,
        'notes': notes,
      };

  static const List<String> _monthNames = [
    '', // index 0 unused
    'Baisakh',
    'Jestha',
    'Ashad',
    'Shrawan',
    'Bhadra',
    'Ashwin',
    'Kartik',
    'Mangsir',
    'Poush',
    'Magh',
    'Falgun',
    'Chaitra',
  ];

  static const List<String> _monthNamesNepali = [
    '', // index 0 unused
    'बैशाख',
    'जेठ',
    'असार',
    'श्रावण',
    'भाद्रपद',
    'असोज',
    'कार्तिक',
    'मंसिर',
    'पौष',
    'माघ',
    'फाल्गुन',
    'चैत्र',
  ];

  static String monthName(int month) =>
      month >= 1 && month <= 12 ? _monthNames[month] : 'Unknown';

  static String monthNameNepali(int month) =>
      month >= 1 && month <= 12 ? _monthNamesNepali[month] : 'Unknown';

  @override
  String toString() => '$bsMonthName $bsYear ($daysInMonth days, $adStart → $adEnd)';
}
