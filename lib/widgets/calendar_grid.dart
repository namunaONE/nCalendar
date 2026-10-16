import 'package:flutter/material.dart';
import 'package:n_calendar/models/bs_day.dart';
import 'package:n_calendar/models/bs_month.dart';
import 'package:n_calendar/services/bs_data_service.dart';

/// A monthly calendar grid showing Bikram Sambat dates with AD conversion.
///
/// Each cell shows the BS day, the mapped AD date, weekday, tithi, and any
/// festival. Built to consume the nCalander evidence-tagged data commons.
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
  BsMonth? _month;
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
      setState(() {
        _month = BsDataService.instance.months.firstWhere(
          (m) => m.bsYear == widget.bsYear && m.bsMonth == widget.bsMonth,
          orElse: () => throw StateError('Month not found'),
        );
        _error = null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null || _month == null) {
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

    final month = _month!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: BS month/year + AD range
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${month.bsMonthName} ${month.bsYear}',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'AD ${month.adStart} → ${month.adEnd}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 4),
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
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Weekday headers
          SizedBox(
            height: 44,
            child: Row(
              children: [
                for (final wd in _weekdayLabels)
                  Expanded(
                    child: Center(
                      child: Text(
                        wd,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
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
          LayoutBuilder(
            builder: (context, constraints) {
              final cellWidth = constraints.maxWidth / 7;
              final firstDay = month.days.first;
              final startIndex = _weekdayIndex(firstDay.adDate); // 0=Sun

              // Build rows of 7 cells. Pad leading empties so day 1 lands
              // on its correct weekday column.
              final cells = <Widget>[];
              for (var i = 0; i < startIndex; i++) {
                cells.add(_dayCell(null, i, cellWidth));
              }
              for (var i = 0; i < month.days.length; i++) {
                cells.add(_dayCell(month.days[i], (startIndex + i) % 7, cellWidth));
              }
              // Fill trailing empties to complete the last row.
              final trailing = (7 - ((startIndex + month.days.length) % 7)) % 7;
              for (var i = 0; i < trailing; i++) {
                cells.add(_dayCell(null, (startIndex + month.days.length + i) % 7, cellWidth));
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: cellWidth / 96,
                ),
                itemCount: cells.length,
                itemBuilder: (_, i) => cells[i],
              );
            },
          ),

          const SizedBox(height: 32),

          // Legend
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _legendChip('Today', Colors.blue),
              _legendChip('Festival', Colors.orange),
              _legendChip('Weekend', Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  static const _weekdayLabels = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

  /// Compute the weekday index (0=Sun) for an ISO date string.
  int _weekdayIndex(String isoDate) {
    final parts = isoDate.split('-').map(int.parse).toList();
    return DateTime.utc(parts[0], parts[1], parts[2]).weekday % 7;
  }

  Widget _dayCell(BsDay? day, int weekdayIndex, double cellWidth) {
    final isWeekend = weekdayIndex == 0 || weekdayIndex == 6;
    final hasFestival = day?.festival != null && day!.festival!.isNotEmpty;

    return Container(
      width: cellWidth,
      height: 96,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 0.5,
        ),
        color: isWeekend
            ? Theme.of(context).colorScheme.surfaceContainerLowest
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (day == null) ...[
              const SizedBox(height: 4),
              Center(
                child: Text(
                  '',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.transparent),
                ),
              ),
            ] else ...[
              Text(
                '${day.bsDay}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: hasFestival
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : null,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                day.weekdayNepali.isNotEmpty
                    ? '${day.weekdayNepali} (${day.weekday})'
                    : day.weekday,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                day.adDate,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              if (day.tithi.isNotEmpty)
                Text(
                  day.tithi,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              if (hasFestival) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    day.festival!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer,
                          fontWeight: FontWeight.w600,
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
