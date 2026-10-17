import 'package:flutter/material.dart';
import 'package:n_calendar/core/models/bs_day.dart';
import 'package:n_calendar/core/models/bs_month.dart';
import 'package:n_calendar/services/bs_data_service.dart';
import 'package:n_calendar/services/festival_service.dart';
import 'package:n_calendar/services/today_service.dart';

/// AD <-> BS date converter built on the nCalander data commons.
///
/// Every conversion is an EXACT lookup inside the shipped, evidence-
/// tagged dataset (calendar.csv -> bs_data.json, BS 1975-2083, AD
/// 1918-04-13 to 2027-04-13). Dates outside that range fail loudly
/// with an honest warning — nCalendar never guesses a conversion.
class DateConverter extends StatefulWidget {
  const DateConverter({super.key, this.initialAdDate});

  /// Optional AD date converted immediately on open (used by tests to
  /// make the result card deterministic).
  final DateTime? initialAdDate;

  @override
  State<DateConverter> createState() => _DateConverterState();
}

class _DateConverterState extends State<DateConverter> {
  static const List<String> _weekdaysFull = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  BsDay? _result;
  String? _error;
  DateTime? _pickedAd;
  bool _bsSeeded = false;
  int _bsYear = 2083;
  int _bsMonth = 1;
  int _bsDay = 1;

  @override
  void initState() {
    super.initState();
    if (widget.initialAdDate != null) {
      _lookupAd(widget.initialAdDate!);
    }
  }

  List<BsMonth> get _months => BsDataService.instance.months;

  String get _minAd => _months.isEmpty ? '1918-04-13' : _months.first.adStart;

  String get _maxAd => _months.isEmpty ? '2027-04-13' : _months.last.adEnd;

  int get _minBsYear => _months.isEmpty ? 1975 : _months.first.bsYear;

  int get _maxBsYear => _months.isEmpty ? 2083 : _months.last.bsYear;

  String _two(int n) => n.toString().padLeft(2, '0');

  String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${_two(d.month)}-${_two(d.day)}';

  /// Exact reverse lookup: AD date -> BS day (or an honest out-of-range
  /// error message; never a guess).
  void _lookupAd(DateTime date) {
    final iso = _iso(date);
    _pickedAd = date;
    final day = BsDataService.instance.dayForAdDate(iso);
    if (day == null) {
      _result = null;
      _error = '$iso is outside the shipped calendar data (supported: '
          'AD $_minAd to $_maxAd, BS $_minBsYear-$_maxBsYear). '
          'nCalendar never guesses a conversion.';
    } else {
      _result = day;
      _error = null;
    }
  }

  Future<void> _pickAdDate() async {
    if (_months.isEmpty) return;
    final first = DateTime.parse(_minAd);
    final last = DateTime.parse(_maxAd);
    var initial =
        _pickedAd ?? DateTime.tryParse(TodayService.instance.todayAdDate);
    if (initial == null || initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      helpText: 'Select AD date',
    );
    if (picked == null || !mounted) return;
    setState(() => _lookupAd(picked));
  }

  /// Seed the BS -> AD dropdowns with today (falls back to the latest
  /// Baisakh when today is outside the shipped range, e.g. post-2027).
  void _ensureBsSeeded() {
    if (_bsSeeded || _months.isEmpty) return;
    final today = TodayService.instance.today();
    if (today != null) {
      _bsYear = today.bsYear;
      _bsMonth = today.bsMonth;
      _bsDay = today.bsDay;
    } else {
      final baisakh = _months.lastWhere((m) => m.bsMonth == 1);
      _bsYear = baisakh.bsYear;
      _bsMonth = 1;
      _bsDay = 1;
    }
    _bsSeeded = true;
  }

  int get _daysInSelectedBsMonth {
    for (final m in _months) {
      if (m.bsYear == _bsYear && m.bsMonth == _bsMonth) return m.daysInMonth;
    }
    return 31;
  }

  void _convertBs() {
    final day = BsDataService.instance.dayAt(_bsYear, _bsMonth, _bsDay);
    setState(() {
      if (day == null) {
        _result = null;
        _error = 'BS $_bsYear-$_bsMonth-$_bsDay does not exist in the '
            'shipped calendar data.';
      } else {
        _result = day;
        _error = null;
        _pickedAd = DateTime.parse(day.adDate);
      }
    });
  }

  String _fullWeekday(String iso) =>
      _weekdaysFull[DateTime.parse(iso).weekday - 1];

  BsMonth? _monthOf(BsDay day) {
    for (final m in _months) {
      if (m.bsYear == day.bsYear && m.bsMonth == day.bsMonth) return m;
    }
    return null;
  }

  Widget _resultCard(BsDay day) {
    final festival = FestivalService.festivalFor(day);
    final month = _monthOf(day);
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${BsMonth.monthName(day.bsMonth)} ${day.bsDay}, ${day.bsYear}',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'AD date:',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                Text(day.adDate),
              ],
            ),
            Row(
              children: [
                Text(
                  'Weekday:',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                Text(_fullWeekday(day.adDate)),
              ],
            ),
            Row(
              children: [
                Text(
                  'Nepali weekday:',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                Text(day.weekdayNepali),
              ],
            ),
            if (festival != null) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  festival,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Evidence: ${month?.evidence ?? 'unknown'} — exact lookup in the shipped dataset',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorCard(String message) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: scheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: scheme.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_months.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Calendar data is not loaded yet.'),
        ),
      );
    }
    _ensureBsSeeded();
    final daysInMonth = _daysInSelectedBsMonth;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Supported range: AD $_minAd to $_maxAd (BS $_minBsYear-$_maxBsYear)',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            'Every conversion is an exact lookup in the shipped, '
            'evidence-tagged dataset — out-of-range dates fail honestly, '
            'never a guess.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),

          // AD -> BS
          Text(
            'AD → BS',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickAdDate,
            icon: const Icon(Icons.calendar_today),
            label: Text(_pickedAd == null
                ? 'Pick an AD date'
                : 'AD: ${_iso(_pickedAd!)}'),
          ),
          const SizedBox(height: 16),

          // BS -> AD
          Text(
            'BS → AD',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 110,
                child: DropdownButton<int>(
                  value: _bsYear,
                  isExpanded: true,
                  items: List.generate(
                          _maxBsYear - _minBsYear + 1, (i) => _minBsYear + i)
                      .map((y) => DropdownMenuItem(
                            value: y,
                            child: Text('$y'),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() {
                    _bsYear = v!;
                    final dim = _daysInSelectedBsMonth;
                    if (_bsDay > dim) _bsDay = dim;
                  }),
                ),
              ),
              SizedBox(
                width: 170,
                child: DropdownButton<int>(
                  value: _bsMonth,
                  isExpanded: true,
                  items: List.generate(12, (i) => i + 1)
                      .map((m) => DropdownMenuItem(
                            value: m,
                            child: Text(BsMonth.monthName(m)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() {
                    _bsMonth = v!;
                    final dim = _daysInSelectedBsMonth;
                    if (_bsDay > dim) _bsDay = dim;
                  }),
                ),
              ),
              SizedBox(
                width: 90,
                child: DropdownButton<int>(
                  value: _bsDay,
                  isExpanded: true,
                  items: List.generate(daysInMonth, (i) => i + 1)
                      .map((d) => DropdownMenuItem(
                            value: d,
                            child: Text('$d'),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _bsDay = v!),
                ),
              ),
              FilledButton.icon(
                onPressed: _convertBs,
                icon: const Icon(Icons.swap_vert),
                label: const Text('Convert'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Result / error
          if (_error != null)
            _errorCard(_error!)
          else if (_result != null)
            _resultCard(_result!),
        ],
      ),
    );
  }
}
