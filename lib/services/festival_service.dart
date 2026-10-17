import 'package:nbs/bs_day.dart';

/// Festival data for BS 2083, cross-referenced from verified sources:
/// - nepalicalendar.online (NPNS-following), nepalipatro.com.np, hamropatro.com
/// - printed Surya Panchang 2083 (NPNS-approved) for print-adjudicated dates
/// - drikpanchang tithi timings for cross-checks
///
/// Each entry maps an AD date (yyyy-MM-dd) to a festival name. AD dates
/// are checked against the verified calendar.csv chain.
///
/// Corrections from the 2026-10-16 audit (all chain- or source-verified):
/// - Indra Jatra main day = Sep 25 (removed an erroneous Sep 10 entry).
/// - Kojagrat Purnima Oct 26 -> Oct 25: the printed Surya Panchang vrata
///   window (11:04->22:33) provisionally wins the evidence ladder. Linear
///   issue HYA-371 remains open pending the government holiday list.
/// - Mha Puja / Nepal Sambat New Year Nov 9 -> Nov 10 (Govardhan Puja
///   stays Nov 9).
/// - Nepali New Year 2084 Apr 13 -> Apr 14 2027 (chain: Chaitra 30 2083
///   = Apr 13; official Baisakh 1 2084 = Wed, Apr 14 2027).
/// - Maghe Sankranti / Maghi Jan 14 -> Jan 15 2027 (chain: Magh 1 2083
///   = Jan 15; Makara sankranti ingress Jan 14 21:16 IST -> +1).
///
/// TODO(festival_rules, Linear HYA-367): the remaining lunar-dated
/// entries (Teej, Laxmi Puja, Buddha Jayanti, Shivaratri, Basant
/// Panchami, ...) still need the explicit-window festival_rules module
/// with per-festival rule basis and sources; solar-ruled dates are
/// already chain-verifiable.
class FestivalService {
  FestivalService._();

  static final FestivalService instance = FestivalService._();

  /// AD date -> festival name (BS 2083).
  static final Map<String, String> _festivals2083 = {
    // Baisakh 2083 (Apr-May 2026)
    '2026-04-14': 'Nepali New Year / Bisket Jatra',
    '2026-04-27': 'Loktantra Diwas (Democracy Day)',
    '2026-05-12': 'Buddha Jayanti',
    // Jestha 2083 (May-Jun 2026)
    '2026-05-29': 'Sithi Nakha',
    '2026-06-02': 'Shani Jayanti',
    // Ashad 2083 (Jun-Jul 2026)
    '2026-06-29': 'Guru Purnima / Guru Poornima',
    '2026-07-11': 'Nag Panchami',
    // Shrawan 2083 (Jul-Aug 2026)
    '2026-07-27': 'Shrawan Sankranti',
    '2026-08-05': 'Janai Purnima / Raksha Bandhan',
    '2026-08-06': 'Gai Jatra',
    // Bhadra 2083 (Aug-Sep 2026)
    '2026-08-28': 'Krishna Janmashtami',
    '2026-09-06': 'Rishi Panchami / Teej',
    // Ashwin 2083 (Sep-Oct 2026)
    '2026-09-17': 'Kanya Sankranti (Ashwin 1)',
    '2026-09-19': 'Constitution Day (संविधान दिवस)',
    '2026-09-22': 'Haripariwartini Ekadashi',
    '2026-09-25': 'Indra Jatra (Kathmandu) - main day',
    '2026-10-11': 'Ghatasthapana (Dashain start)',
    '2026-10-18': 'Fulpati / Maha Ashtami',
    '2026-10-20': 'Maha Navami',
    '2026-10-21': 'Vijaya Dashami (Dashain main day)',
    '2026-10-25': 'Kojagrat Purnima',
    // Kartik 2083 (Oct-Nov 2026)
    '2026-11-07': 'Kag Tihar / Kaag Puja',
    '2026-11-08': 'Laxmi Puja (Tihar main day)',
    '2026-11-09': 'Govardhan Puja',
    '2026-11-10': 'Mha Puja / Nepal Sambat New Year 1147',
    '2026-11-11': 'Bhai Tika',
    '2026-11-15': 'Chhath Puja',
    // Mangsir 2083 (Nov-Dec 2026)
    '2026-11-24': 'Utkauli / Ubhauli',
    '2026-12-01': 'Bala Chaturdashi',
    '2026-12-05': 'Vivah Panchami',
    // Poush 2083 (Dec 2026-Jan 2027)
    '2026-12-25': 'Christmas (public holiday)',
    // Magh 2083 (Jan-Feb 2027)
    '2027-01-15': 'Maghe Sankranti / Maghi (Tharu New Year)',
    '2027-01-29': 'Basant Panchami / Saraswati Puja',
    // Falgun 2083 (Feb-Mar 2027)
    '2027-02-27': 'Maha Shivaratri',
    '2027-03-07': 'Fagu Purnima / Holi',
    // Chaitra 2083 (Mar-Apr 2027)
    '2027-03-22': 'Chaitra Dashain / Chaite Dashain',
    '2027-03-29': 'Ram Nawami',
    '2027-04-14': 'Nepali New Year 2084 (Baisakh 1)',
  };

  /// Look up the festival name for a given [BsDay], if any.
  static String? festivalFor(BsDay day) {
    return _festivals2083[day.adDate];
  }
}
