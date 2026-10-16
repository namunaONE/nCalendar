import 'package:flutter/material.dart';
import 'package:n_calendar/models/bs_day.dart';
import 'package:n_calendar/models/bs_month.dart';
import 'package:n_calendar/services/bs_data_service.dart';
import 'package:n_calendar/theme/n_calendar_theme.dart';

/// A monthly calendar grid showing Bikram Sambat dates with AD conversion.
///
/// Each cell shows the BS day, the mapped AD date, weekday, tithi, and any
/// festival. Built to consume the nCalander evidence-tagged data commons.
///
/// Responsive behavior (via [LayoutBuilder]):
/// - xs/sm (< 900px): single month, vertical stack
/// - md/lg (>= 900px): two or more months side-by-side, denser cells
class CalendarGrid extends StatefulWidget {
  final int bsYear;
  final int bsMonth;

  const CalendarGrid({
    super.key,
    required this.bsYear,
    required this.bsMonth,
  });

  @override
  State<CalendarGrid> createState() => _CalendarGridState();
}

class _CalendarGridState extends State<CalendarGrid> {
  List<BsMonth> _months = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      await BsDataService.instance.load();
      final service = BsDataService.instance;
      // Load all months for the selected year so we can render a year view.
      _months = service.months
          .where((m) => m.bsYear == widget.bsYear)
          .toList()
        ..sort((a, b) => a.bsMonth.compareTo(b.bsMonth));
      setState(() {
        _error = null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  int _monthCountForWidth(double width) {
    if (width >= 1200) return 3;
    if (width >= 900) return 2;
    return 1;
  }

  Widget _monthGrid(BsMonth month, double cellWidth, double cellHeight) {
    final firstDay = month.days.first;
    final startIndex = _weekdayIndex(firstDay.adDate); // 0=Sun

    final cells = <Widget>[];
    for (var i = 0; i < startIndex; i++) {
      cells.add(_dayCell(null, i, cellWidth, cellHeight));
    }
    for (var i = 0; i < month.days.length; i++) {
      cells.add(_dayCell(
          month.days[i], (startIndex + i) % 7, cellWidth, cellHeight));
    }
    final trailing = (7 - ((startIndex + month.days.length) % 7)) % 7;
    for (var i = 0; i < trailing; i++) {
      cells.add(_dayCell(
          null, (startIndex + month.days.length + i) % 7, cellWidth, cellHeight));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${month.bsMonthName} ${month.bsYear}',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'AD ${month.adStart} → ${month.adEnd}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${month.daysInMonth} days · NPT (UTC+05:45)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Refresh'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Weekday headers
        SizedBox(
          height: 36,
          child: Row(
            children: [
              for (final wd in _weekdayLabels)
                Expanded(
                  child: Center(
                    child: Text(
                      wd,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Grid cells
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: cellWidth / cellHeight,
            mainAxisSpacing: 0.5,
            crossAxisSpacing: 0.5,
          ),
          itemCount: cells.length,
          itemBuilder: (_, i) => cells[i],
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  static const _weekdayLabels = [
    'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat',
  ];

  int _weekdayIndex(String isoDate) {
    final parts = isoDate.split('-').map(int.parse).toList();
    return DateTime.utc(parts[0], parts[1], parts[2]).weekday % 7;
  }

  Widget _dayCell(BsDay? day, int weekdayIndex,
      double cellWidth, double cellHeight) {
    final isWeekend = weekdayIndex == 0 || weekdayIndex == 6;
    final hasFestival = day?.festival != null && day!.festival!.isNotEmpty;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: cellWidth,
      height: cellHeight,
      decoration: BoxDecoration(
        border: Border.all(
          color: scheme.outlineVariant,
          width: 0.5,
        ),
        color: isWeekend
            ? scheme.surfaceContainerLowest
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (day == null) ...[
              const SizedBox(height: 4),
            ] else ...[
              Text(
                '${day.bsDay}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: hasFestival
                          ? scheme.onPrimaryContainer
                          : null,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                day.weekdayNepali.isNotEmpty
                    ? '${day.weekdayNepali} (${day.weekday})'
                    : day.weekday,
                style: Theme.of(context).textTheme.labelSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                day.adDate,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (day.tithi.isNotEmpty)
                Text(
                  day.tithi,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                        fontSize: 10,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              if (hasFestival) ...[
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5, vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    day.festival!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null || _months.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Failed to load calendar data',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: _load,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final monthCount = _monthCountForWidth(constraints.maxWidth);
        // Reserve ~40px for padding + header, then divide remaining width.
        const gridPadding = 48.0;
        const cellHeight = 84.0;
        final availableWidth = constraints.maxWidth - gridPadding;
        final cellWidth = availableWidth / (monthCount * 7);

        final yearMonths = _months.take(monthCount).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${yearMonths.first.bsMonthName} ${yearMonths.first.bsYear}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'AD ${yearMonths.first.adStart} → ${yearMonths.last.adEnd}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${yearMonths.fold<int>(0, (sum, m) => sum + m.daysInMonth)} total days · NPT (UTC+05:45)',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Month grids side-by-side (responsive)
              Wrap(
                spacing: 16,
                runSpacing: 24,
                children: yearMonths.map((month) {
                  return SizedBox(
                    width: availableWidth / monthCount - 16,
                    child: _monthGrid(month, cellWidth, cellHeight),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // Legend
              Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _legendChip('Today', NCalendarTheme.growthGreen),
                  _legendChip('Festival', NCalendarTheme.growthGreen),
                  _legendChip('Weekend', Colors.grey),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _legendChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
