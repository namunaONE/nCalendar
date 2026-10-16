import 'package:flutter/material.dart';
import 'package:n_calendar/models/bs_day.dart';
import 'package:n_calendar/models/bs_month.dart';
import 'package:n_calendar/services/bs_data_service.dart';
import 'package:n_calendar/services/festival_service.dart';
import 'package:n_calendar/services/today_service.dart';
import 'package:n_calendar/theme/n_calendar_theme.dart';

/// A monthly / yearly calendar grid showing Bikram Sambat dates with AD conversion.
///
/// Each cell shows the BS day, the mapped AD date, weekday, tithi, and any
/// festival. Built to consume the nCalander evidence-tagged data commons.
///
/// Responsive behavior (via [LayoutBuilder] + [NCalendarTheme]):
/// - xs (< 480px): single month, large touch targets
/// - sm (480–768px): single column, 1–2 months
/// - md (768–1024px): 2–3 months side-by-side
/// - lg (1024–1400px): 3–4 months side-by-side
/// - xl (> 1400px): 4–6 months side-by-side, full year view
class CalendarGrid extends StatefulWidget {
  final int bsYear;
  final int bsMonth; // 1 = Baisakh ... 12 = Chaitra — the user-selected month

  const CalendarGrid({
    super.key,
    required this.bsYear,
    required this.bsMonth,
  });

  @override
  State<CalendarGrid> createState() => _CalendarGridState();
}

class _CalendarGridState extends State<CalendarGrid> {
  List<BsMonth> _yearMonths = [];
  bool _loading = true;
  String? _error;
  BsDay? _todayDay;
  bool _yearView = false; // true = show all 12 months at once

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
      _yearMonths = service.months
          .where((m) => m.bsYear == widget.bsYear)
          .toList()
        ..sort((a, b) => a.bsMonth.compareTo(b.bsMonth));
      // Attach festival data to each day.
      for (final m in _yearMonths) {
        for (final d in m.days) {
          d.festival = FestivalService.festivalFor(d);
        }
      }
      // Detect today's BS date.
      _todayDay = TodayService.instance.today();
      setState(() => _error = null);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  BsMonth? get _selectedMonth {
    try {
      return _yearMonths.firstWhere((m) => m.bsMonth == widget.bsMonth);
    } on StateError {
      return null;
    }
  }

  Widget _monthGrid(BsMonth month, double cellWidth, double cellHeight,
      {bool isSelected = false, bool compact = false}) {
    final firstDay = month.days.first;
    final startIndex = _weekdayIndex(firstDay.adDate); // 0=Sun

    final todayAdDate = TodayService.instance.todayAdDate;
    final textScale = NCalendarTheme.responsiveTextScale(context);
    final cells = <Widget>[];
    for (var i = 0; i < startIndex; i++) {
      cells.add(_dayCell(null, i, cellWidth, cellHeight));
    }
    for (var i = 0; i < month.days.length; i++) {
      final day = month.days[i];
      cells.add(_dayCell(
        day,
        (startIndex + i) % 7,
        cellWidth,
        cellHeight,
        isToday: day.adDate == todayAdDate,
      ));
    }
    final trailing = (7 - ((startIndex + month.days.length) % 7)) % 7;
    for (var i = 0; i < trailing; i++) {
      cells.add(_dayCell(
          null, (startIndex + month.days.length + i) % 7, cellWidth, cellHeight));
    }

    final scheme = Theme.of(context).colorScheme;
    final pad = textScale.clamp(0.8, 1.3) * 8.0;

    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: isSelected
            ? scheme.primaryContainer.withValues(alpha: 0.15)
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: scheme.primary, width: 2)
            : null,
      ),
      child: Column(
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
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? scheme.primary : null,
                          ),
                    ),
                    if (isSelected)
                      SizedBox(height: 2 * textScale),
                    if (isSelected)
                      Text(
                        'SELECTED',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 10 * textScale,
                        ),
                      ),
                    SizedBox(height: 4 * textScale),
                    Text(
                      'AD ${month.adStart} → ${month.adEnd}',
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontSize: 14 * textScale,
                      ),
                    ),
                    SizedBox(height: 2 * textScale),
                    Text(
                      '${month.daysInMonth} days · NPT (UTC+05:45) · ${month.evidence}',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontSize: 11 * textScale,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle,
                    color: scheme.primary,
                    size: 20 * textScale),
            ],
          ),
          if (!compact) ...[
            SizedBox(height: 12 * textScale),

            // Weekday headers
            SizedBox(
              height: 34 * textScale,
              child: Row(
                children: [
                  for (final wd in _weekdayLabels)
                    Expanded(
                      child: Center(
                        child: Text(
                          wd,
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurfaceVariant,
                            fontSize: 12 * textScale,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],

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
        ],
      ),
    );
  }

  /// Compact mini-month for year view: month header + day numbers only.
  Widget _miniMonth(BsMonth month, double cellSize) {
    final firstDay = month.days.first;
    final startIndex = _weekdayIndex(firstDay.adDate); // 0=Sun

    final todayAdDate = TodayService.instance.todayAdDate;
    final textScale = NCalendarTheme.responsiveTextScale(context);
    final cells = <Widget>[];
    for (var i = 0; i < startIndex; i++) {
      cells.add(SizedBox.square(dimension: cellSize));
    }
    for (var i = 0; i < month.days.length; i++) {
      final day = month.days[i];
      final hasFestival =
          day.festival != null && day.festival!.isNotEmpty;
      final isToday = day.adDate == todayAdDate;
      final scheme = Theme.of(context).colorScheme;
      cells.add(
        Container(
          width: cellSize,
          height: cellSize,
          decoration: BoxDecoration(
            color: isToday
                ? NCalendarTheme.growthGreen.withValues(alpha: 0.4)
                : hasFestival
                    ? scheme.primaryContainer.withValues(alpha: 0.12)
                    : null,
            borderRadius: BorderRadius.circular(6),
            border: isToday
                ? Border.all(color: NCalendarTheme.growthGreen, width: 1.5)
                : null,
          ),
          child: Center(
            child: Text(
              '${day.bsDay}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 11 * textScale,
                    color: isToday
                        ? NCalendarTheme.growthGreen
                        : hasFestival
                            ? scheme.onPrimaryContainer
                            : null,
                  ),
            ),
          ),
        ),
      );
    }
    final trailing = (7 - ((startIndex + month.days.length) % 7)) % 7;
    for (var i = 0; i < trailing; i++) {
      cells.add(SizedBox.square(dimension: cellSize));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          month.bsMonthName,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 12 * textScale,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        SizedBox(height: 6 * textScale),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.0,
            mainAxisSpacing: 2 * textScale,
            crossAxisSpacing: 2 * textScale,
          ),
          itemCount: cells.length,
          itemBuilder: (_, i) => cells[i],
        ),
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
      double cellWidth, double cellHeight, {bool isToday = false}) {
    final isWeekend = weekdayIndex == 0 || weekdayIndex == 6;
    final hasFestival = day?.festival != null && day!.festival!.isNotEmpty;
    final scheme = Theme.of(context).colorScheme;
    final textScale = NCalendarTheme.responsiveTextScale(context);
    final isSelectedToday = isToday && day?.adDate == _todayDay?.adDate;

    return Container(
      width: cellWidth,
      height: cellHeight,
      decoration: BoxDecoration(
        border: isSelectedToday
            ? Border.all(color: NCalendarTheme.growthGreen, width: 2)
            : Border.all(
                color: scheme.outlineVariant,
                width: 0.5,
              ),
        color: isSelectedToday
            ? scheme.secondaryContainer.withValues(alpha: 0.35)
            : isWeekend
                ? scheme.surfaceContainerLowest
                : null,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 6 * textScale,
          horizontal: 3 * textScale,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (day == null) ...[
                SizedBox(height: 4 * textScale),
              ] else ...[
                Text(
                  '${day.bsDay}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: hasFestival
                            ? scheme.onPrimaryContainer
                            : null,
                        fontSize: 14 * textScale,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 1 * textScale),
                Text(
                  day.weekdayNepali.isNotEmpty
                      ? '${day.weekdayNepali} (${day.weekday})'
                      : day.weekday,
                  style: Theme.of(context).textTheme.labelSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 1 * textScale),
                Text(
                  day.adDate,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontSize: 11 * textScale,
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
                          fontSize: 10 * textScale,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (hasFestival) ...[
                  SizedBox(height: 3 * textScale),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5 * textScale,
                      vertical: 1 * textScale,
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
                            fontSize: 10 * textScale,
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
      ),
    );
  }

  Widget _legendChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: NCalendarTheme.minTouchTarget * 0.18,
            height: NCalendarTheme.minTouchTarget * 0.18,
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null || _yearMonths.isEmpty) {
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

    final breakPoint = NCalendarTheme.breakpointOf(context);
    final isMobile = breakPoint == 'xs' || breakPoint == 'sm';
    final todayDay = _todayDay;
    final padding = NCalendarTheme.responsivePadding(context);
    final textScale = NCalendarTheme.responsiveTextScale(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Pre-compute layout values available in LayoutBuilder scope
        final availableWidth = constraints.maxWidth - padding * 2;
        final cols = isMobile ? 1 : NCalendarTheme.monthCountForWidth(
          constraints.maxWidth,
        );
        final yearCellSize = (availableWidth / cols - 32) / 7;
        final cellHeight = 84.0 * textScale.clamp(0.9, 1.2);
        final monthCount =
            NCalendarTheme.monthCountForWidth(constraints.maxWidth);
        final monthViewWidth = constraints.maxWidth - padding * 2;
        final cellWidth = monthViewWidth / (monthCount * 7);
        final List<BsMonth> showMonths;
        if (isMobile) {
          showMonths = [_selectedMonth!];
        } else {
          showMonths = _yearMonths.take(monthCount).toList();
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: year + view toggle
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _yearView
                              ? '${widget.bsYear} — Full Year'
                              : '${_selectedMonth?.bsMonthName ?? ''} ${widget.bsYear}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 22 * textScale,
                          ),
                        ),
                        SizedBox(height: 4 * textScale),
                        if (!_yearView && _selectedMonth != null)
                          Text(
                            'AD ${_selectedMonth!.adStart} → ${_selectedMonth!.adEnd}',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: 16 * textScale,
                            ),
                          ),
                        if (_yearView)
                          Text(
                            'AD ${_yearMonths.first.adStart} → ${_yearMonths.last.adEnd} · ${_yearMonths.length} months',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: 14 * textScale,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => setState(() => _yearView = false),
                        icon: Icon(Icons.calendar_month, size: 18 * textScale),
                        label: Text(
                          'Month View',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _yearView
                              ? null
                              : Theme.of(context).colorScheme.primary,
                          minimumSize: Size(
                            NCalendarTheme.minTouchTarget * 0.7,
                            NCalendarTheme.minTouchTarget,
                          ),
                        ),
                      ),
                      SizedBox(width: 8 * textScale),
                      OutlinedButton.icon(
                        onPressed: () => setState(() => _yearView = true),
                        icon: Icon(Icons.view_list, size: 18 * textScale),
                        label: Text(
                          'Year View',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _yearView
                              ? Theme.of(context).colorScheme.primary
                              : null,
                          minimumSize: Size(
                            NCalendarTheme.minTouchTarget * 0.7,
                            NCalendarTheme.minTouchTarget,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12 * textScale),

              // Today banner (shown when today's month is displayed in month view)
              if (!_yearView &&
                  todayDay != null &&
                  todayDay.bsYear == widget.bsYear &&
                  todayDay.bsMonth == widget.bsMonth)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16 * textScale,
                    vertical: 10 * textScale,
                  ),
                  decoration: BoxDecoration(
                    color: NCalendarTheme.growthGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: NCalendarTheme.growthGreen.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.today,
                        color: NCalendarTheme.growthGreen,
                        size: 18 * textScale,
                      ),
                      SizedBox(width: 8 * textScale),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Today: ${todayDay.bsDay} ${BsMonth.monthName(todayDay.bsMonth)} ${todayDay.bsYear}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: NCalendarTheme.growthGreen,
                                fontSize: 14 * textScale,
                              ),
                            ),
                            SizedBox(height: 2 * textScale),
                            Text(
                              'AD ${todayDay.adDate} · ${todayDay.weekdayNepali}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                color: NCalendarTheme.growthGreen,
                                fontSize: 12 * textScale,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              if (!_yearView &&
                  todayDay != null &&
                  todayDay.bsYear == widget.bsYear &&
                  todayDay.bsMonth == widget.bsMonth)
              SizedBox(height: 8 * textScale),

              // Content: Year View or Month View
              if (_yearView) ...[
                // Full year view: 12 months in 3 columns × 4 rows
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    childAspectRatio: isMobile ? 1.6 : 1.15,
                    mainAxisSpacing: 16 * textScale,
                    crossAxisSpacing: 16 * textScale,
                  ),
                  itemCount: _yearMonths.length,
                  itemBuilder: (_, i) {
                    final month = _yearMonths[i];
                    return _miniMonth(month, yearCellSize);
                  },
                ),
              ] else ...[
                // Month view: responsive 1/2/3 months side-by-side
                Wrap(
                  spacing: 16 * textScale,
                  runSpacing: 24 * textScale,
                  children: showMonths.map((month) {
                    return SizedBox(
                      width: monthViewWidth / monthCount - 16,
                      child: _monthGrid(
                        month,
                        cellWidth,
                        cellHeight,
                        isSelected: month.bsMonth == widget.bsMonth,
                      ),
                    );
                  }).toList(),
                ),
              ],

              SizedBox(height: 32 * textScale),

              // Legend
              Wrap(
                spacing: 12 * textScale,
                runSpacing: 8 * textScale,
                alignment: WrapAlignment.center,
                children: [
                  _legendChip('Today', NCalendarTheme.growthGreen),
                  _legendChip('Festival', NCalendarTheme.growthGreen),
                  _legendChip('Weekend', Colors.grey),
                  if (! _yearView)
                    _legendChip(
                        'Selected month', NCalendarTheme.primaryNavy),
                ],
              ),

              SizedBox(height: 24 * textScale),
            ],
          ),
        );
      },
    );
  }  // Close build method
}  // Close class