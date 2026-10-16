/// A single day in the Bikram Sambat (BS) calendar, mapped to its AD date.
///
/// This mirrors one row of the nCalander evidence-tagged data commons
/// (calendar.csv / JSON). The real commons data should replace the sample
/// in `assets/bs_data.json`.
class BsDay {
  final int bsDay;
  final String adDate; // ISO yyyy-MM-dd (Nepal civil date, NPT)
  final String weekday;
  final String weekdayNepali;
  final String tithi;
  String? festival;

  BsDay({
    required this.bsDay,
    required this.adDate,
    required this.weekday,
    required this.weekdayNepali,
    required this.tithi,
    this.festival,
  });

  factory BsDay.fromJson(Map<String, dynamic> json) => BsDay(
        bsDay: json['bsDay'] as int,
        adDate: json['adDate'] as String,
        weekday: json['weekday'] as String,
        weekdayNepali: json['weekdayNepali'] as String,
        tithi: json['tithi'] as String,
        festival: json['festival'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'bsDay': bsDay,
        'adDate': adDate,
        'weekday': weekday,
        'weekdayNepali': weekdayNepali,
        'tithi': tithi,
        'festival': festival,
      };

  /// Parse yyyy-MM-dd into a DateTime (UTC midnight).
  DateTime get adDateTime {
    final parts = adDate.split('-').map(int.parse).toList();
    return DateTime.utc(parts[0], parts[1], parts[2]);
  }

  @override
  String toString() => 'BsDay $bsDay -> $adDate ($weekday, $tithi)';

  // Populated by BsMonth after construction; kept here for convenience.
  int get bsYear => _bsYear;
  int get bsMonth => _bsMonth;

  int _bsYear = 0;
  int _bsMonth = 0;
  void setMonthContext(int year, int month) {
    _bsYear = year;
    _bsMonth = month;
  }
}
