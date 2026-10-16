import 'package:flutter/material.dart';
import 'package:n_calendar/models/bs_month.dart';
import 'package:n_calendar/services/bs_data_service.dart';
import 'package:n_calendar/widgets/calendar_grid.dart';

void main() {
  runApp(const NCalendarApp());
}

class NCalendarApp extends StatelessWidget {
  const NCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'nCalendar',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF002C6D), // brand navy seed
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF002C6D),
          brightness: Brightness.dark,
        ),
      ),
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
  bool _loading = true;
  List<BsMonth> _months = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('nCalendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _init,
            tooltip: 'Reload data',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Month/year selector
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                      SizedBox(
                        width: 100,
                        child: DropdownButton<int>(
                          value: _selectedYear,
                          items: List.generate(10, (i) => 2075 + i)
                              .map((y) => DropdownMenuItem(
                                    value: y,
                                    child: Text('$y'),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedYear = v!),
                        ),
                      ),
                      const SizedBox(width: 8),
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
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Calendar grid
                Expanded(
                  child: CalendarGrid(
                    bsYear: _selectedYear,
                    bsMonth: _selectedMonth,
                  ),
                ),
              ],
            ),
      bottomNavigationBar: _currentMonth != null
          ? Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Text(
                'Source: nCalander Commons Layer 1 · NPT (UTC+05:45) · '
                '${_currentMonth!.daysInMonth} days',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            )
          : null,
    );
  }
}
