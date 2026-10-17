/// `nbs` — a pure-Dart Bikram Sambat (BS) calendar core.
///
/// Evidence-tagged BS ↔ AD date conversion that fails honestly: every
/// lookup outside the loaded dataset returns null — never a guess, never
/// an untagged projection presented as fact.
///
/// The package ships the models, the expansion engine, a JSON loader,
/// and the [NbsCalendar] facade. It does NOT bundle calendar data:
/// bring your own evidence-tagged dataset (e.g. the nCalander commons
/// `calendar.csv` / `bs_data.json`, Apache-2.0 / CC0).
library;

export 'bs_calendar_engine.dart';
export 'bs_day.dart';
export 'bs_month.dart';
export 'bs_year.dart';
export 'nbs_calendar.dart';
export 'nbs_data.dart';
