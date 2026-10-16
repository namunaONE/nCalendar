import 'package:n_calendar/models/bs_day.dart';

/// Festival data for BS 2083, cross-referenced from verified web sources:
/// - nepalicalendar.online
/// - nepalipatro.com.np
/// - hamropatro.com
/// - astrosuraksha.com
///
/// Each entry maps an AD date (yyyy-MM-dd) to a festival name.
/// AD dates were looked up against our verified calendar.csv to find
/// the corresponding BS day, so festival labels are attached to the
/// correct BS day in the grid.
class FestivalService {
  FestivalService._();

  static final FestivalService instance = FestivalService._();

  /// AD date → festival name (BS 2083).
  ///
  /// Sources verified against web calendar data. Disputed dates (e.g.
  /// Kojagrat Purnima Oct 25 vs Oct 26) follow the Linear project
  /// R6/R8 adjudication: printed panchang provisionally wins.
  static final Map<String, String> _festivals2083 = {
    // Baisakh 2083 (Apr–May 2026)
    '2026-04-14': 'Nepali New Year / Bisket Jatra',
    '2026-04-27': 'Loktantra Diwas (Democracy Day)',
    '2026-05-12': 'Buddha Jayanti',
    // Jestha 2083 (May–Jun 2026)
    '2026-05-29': 'Sithi Nakha',
    '2026-06-02': 'Shani Jayanti',
    // Ashad 2083 (Jun–Jul 2026)
    '2026-06-29': 'Guru Purnima / Guru Poornima',
    '2026-07-11': 'Nag Panchami',
    // Shrawan 2083 (Jul–Aug 2026)
    '2026-07-27': 'Shrawan Sankranti',
    '2026-08-05': 'Janai Purnima / Raksha Bandhan',
    '2026-08-06': 'Gai Jatra',
    // Bhadra 2083 (Aug–Sep 2026)
    '2026-08-28': 'Krishna Janmashtami',
    '2026-09-06': 'Rishi Panchami / Teej',
    '2026-09-10': 'Indra Jatra',
    // Ashwin 2083 (Sep–Oct 2026)
    '2026-09-17': 'Kanya Sankranti',
    '2026-09-19': 'Constitution Day (संविधान दिवस)',
    '2026-09-22': 'Haripariwartini Ekadashi',
    '2026-09-25': 'Indra Jatra (Kathmandu)',
    '2026-10-11': 'Ghatasthapana (Dashain start)',
    '2026-10-18': 'Maha Ashtami',
    '2026-10-20': 'Maha Navami',
    '2026-10-21': 'Vijaya Dashami (Dashain main day)',
    '2026-10-26': 'Kojagrat Purnima',
    // Kartik 2083 (Oct–Nov 2026)
    '2026-11-07': 'Kag Tihar / Kaag Puja',
    '2026-11-08': 'Laxmi Puja (Tihar main day)',
    '2026-11-09': 'Govardhan Puja / Mha Puja / Nepal Sambat New Year',
    '2026-11-10': 'Bhai Tika',
    '2026-11-15': 'Chhath Puja',
    // Mangsir 2083 (Nov–Dec 2026)
    '2026-11-24': 'Utkauli / Ubhauli',
    '2026-12-01': 'Bala Chaturdashi',
    '2026-12-05': 'Vivah Panchami',
    // Poush 2083 (Dec 2026–Jan 2027)
    '2026-12-25': 'Christmas (public holiday)',
    '2027-01-14': 'Maghe Sankranti',
    // Magh 2083 (Jan–Feb 2027)
    '2027-01-29': 'Basant Panchami / Saraswati Puja',
    '2027-02-10': 'Maghi / Tharu New Year',
    // Falgun 2083 (Feb–Mar 2027)
    '2027-02-27': 'Maha Shivaratri',
    '2027-03-07': 'Fagu Purnima / Holi',
    // Chaitra 2083 (Mar–Apr 2027)
    '2027-03-22': 'Chaitra Dashain / Chaite Dashain',
    '2027-03-29': 'Ram Nawami',
    '2027-04-13': 'Nepali New Year 2084 (Baisakh 1)',
  };

  /// Look up the festival name for a given [BsDay], if any.
  static String? festivalFor(BsDay day) {
    return _festivals2083[day.adDate];
  }
}
