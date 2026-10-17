import 'package:flutter/material.dart';
import 'package:n_calendar/core/models/bs_month.dart';
import 'package:n_calendar/services/bs_data_service.dart';
import 'package:n_calendar/services/today_service.dart';
import 'package:n_calendar/theme/n_calendar_theme.dart';
import 'package:n_calendar/widgets/calendar_grid.dart';

// Deferred import (C1 bundle diet): the converter is compiled into a
// separate dart2js part file and excluded from the initial JS payload.
// It loads on the first switch to the Converter tab via loadLibrary().
import 'package:n_calendar/widgets/date_converter.dart' deferred as converter;

void main() {
  runApp(const NCalendarApp());
}

class NCalendarApp extends StatelessWidget {
  const NCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'nCalendar',
      theme: NCalendarTheme.light(),
      darkTheme: NCalendarTheme.dark(),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedYear = 2083;
  int _selectedMonth = 1; // Baisakh
  int _tabIndex = 0; // 0 = Calendar, 1 = Converter
  bool _openedOnToday = false; // jump to today on the first load only
  bool _loading = true;
  List<BsMonth> _months = [];

  // Deferred converter library state (C1 bundle diet).
  bool _converterLoaded = false;
  bool _converterLoading = false;
  bool _converterError = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await BsDataService.instance.load();
    if (!mounted) return;
    setState(() {
      _months = BsDataService.instance.months;
      _loading = false;
    });
    // Open on today's BS month on the first load; a later refresh must
    // not re-jump away from whatever the user has selected.
    if (!_openedOnToday) {
      _openedOnToday = true;
      _goToToday(selectTab: false);
    }
  }

  void _goToToday({bool selectTab = true}) {
    final today = TodayService.instance.today();
    if (today == null) return;
    setState(() {
      _selectedYear = today.bsYear;
      _selectedMonth = today.bsMonth;
      if (selectTab) _tabIndex = 0;
    });
  }

  void _onTabSelected(int index) {
    setState(() => _tabIndex = index);
    if (index == 1) {
      _ensureConverterLoaded();
    }
  }

  /// Loads the deferred converter library on first use. On failure the
  /// user sees an honest error message and can retry by switching tabs.
  Future<void> _ensureConverterLoaded() async {
    if (_converterLoaded || _converterLoading) return;
    setState(() {
      _converterLoading = true;
      _converterError = false;
    });
    try {
      await converter.loadLibrary();
      _converterLoaded = true;
    } catch (_) {
      _converterError = true;
    } finally {
      _converterLoading = false;
      if (mounted) setState(() {});
    }
  }

  BsMonth? get _currentMonth {
    try {
      return _months.firstWhere(
        (m) => m.bsYear == _selectedYear && m.bsMonth == _selectedMonth,
      );
    } on StateError {
      return null;
    }
  }

  int get _minYear {
    if (_months.isEmpty) return 1975;
    return _months.map((m) => m.bsYear).reduce((a, b) => a < b ? a : b);
  }

  int get _maxYear {
    if (_months.isEmpty) return 2083;
    return _months.map((m) => m.bsYear).reduce((a, b) => a > b ? a : b);
  }

  void _previousYear() {
    if (_selectedYear > _minYear) {
      setState(() => _selectedYear--);
    }
  }

  void _nextYear() {
    if (_selectedYear < _maxYear) {
      setState(() => _selectedYear++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = NCalendarTheme.responsivePadding(context);
    final today = TodayService.instance.today();
    return Scaffold(
      appBar: AppBar(
        title: const Text('nCalendar'),
        actions: [
          if (today != null)
            TextButton.icon(
              onPressed: _goToToday,
              icon: const Icon(Icons.today, size: 18),
              label: Text(
                '${BsMonth.monthName(today.bsMonth)} ${today.bsDay}, ${today.bsYear}',
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _init,
            tooltip: 'Reload data',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _tabIndex,
              children: [
                Column(
                  children: [
                    // Month/year selector
                    Container(
                      padding: EdgeInsets.all(padding),
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        alignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            'Bikram Sambat',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 8),
                          // Previous year
                          FilledButton.tonal(
                            onPressed: _selectedYear > _minYear
                                ? _previousYear
                                : null,
                            child: const Text('◀ Year'),
                          ),
                          // Year dropdown — full data range
                          SizedBox(
                            width: 110,
                            child: DropdownButton<int>(
                              value: _selectedYear,
                              items: List.generate(
                                _maxYear - _minYear + 1,
                                (i) => _minYear + i,
                              )
                                  .map((y) => DropdownMenuItem(
                                        value: y,
                                        child: Text('$y'),
                                      ))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedYear = v!),
                            ),
                          ),
                          // Next year
                          FilledButton.tonal(
                            onPressed: _selectedYear < _maxYear
                                ? _nextYear
                                : null,
                            child: const Text('Year ▶'),
                          ),
                          const SizedBox(width: 16),
                          // Month dropdown
                          SizedBox(
                            width: 170,
                            child: DropdownButton<int>(
                              value: _selectedMonth,
                              items: List.generate(12, (i) => i + 1)
                                  .map((m) => DropdownMenuItem(
                                        value: m,
                                        child: Text(BsMonth.monthName(m)),
                                      ))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedMonth = v!),
                            ),
                          ),
                          if (_currentMonth != null)
                            Text(
                              'AD ${_currentMonth!.adStart} → ${_currentMonth!.adEnd}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500),
                            ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    // Calendar grid (renders its own legend internally)
                    Expanded(
                      child: CalendarGrid(
                        bsYear: _selectedYear,
                        bsMonth: _selectedMonth,
                      ),
                    ),
                  ],
                ),
                // Converter tab: rendered only from the deferred library,
                // with a loading state and an honest error + retry path.
                // NOTE: const is not allowed through a deferred import
                // (constant evaluation precedes loadLibrary()).
                // Idle state renders NOTHING. A permanently mounted
                // (offstage) indeterminate spinner keeps scheduling
                // frames forever: CI pumpAndSettle caught it, and on
                // the deployed app it would burn CPU/battery behind
                // the active tab. Show the spinner only while the
                // deferred library is actually loading.
                _converterLoaded
                    ? converter.DateConverter()
                    : _converterLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : _converterError
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Text(
                                    'Converter failed to load — switch to the '
                                    'Calendar tab and back to retry.',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
              ],
            ),
      bottomNavigationBar: _currentMonth != null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                NavigationBar(
                  selectedIndex: _tabIndex,
                  onDestinationSelected: _onTabSelected,
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.calendar_month),
                      label: 'Calendar',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.swap_horiz),
                      label: 'Converter',
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(padding * 0.75),
                  color:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Text(
                    'Source: nCalander Commons Layer 1 · NPT (UTC+05:45) · '
                    '${_currentMonth!.daysInMonth} days · evidence: ${_currentMonth!.evidence}',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )
          : null,
    );
  }
}
