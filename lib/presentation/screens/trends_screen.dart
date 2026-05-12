import 'package:flutter/material.dart';
import '../../core/app_globals.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models.dart';
import '../providers/health_data_provider.dart';

Color get _creamBg => AppGlobals.creamBg;
Color get _creamCard => AppGlobals.creamCard;
Color get _creamCardTop => AppGlobals.creamCardTop;
Color get _tanButtonLifted => AppGlobals.tanButtonLifted;
Color get _textMain => AppGlobals.textMain;
Color get _textMuted => AppGlobals.textMuted;
Color get _primaryBlack => AppGlobals.primaryBlack;
Color get _vitalSuccess => AppGlobals.vitalSuccess;
Color get _surfaceBorder => AppGlobals.surfaceBorder;
Color get _glowGold => AppGlobals.glowGold;
const _hrPink = Color(0xFFEC4899);

enum _Period { week, month, year }

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key});

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  _Period _period = _Period.week;
  DateTime? _customFrom;

  DateTime _cutoff() {
    if (_customFrom != null) return _customFrom!;
    final now = DateTime.now();
    switch (_period) {
      case _Period.week:
        return now.subtract(const Duration(days: 7));
      case _Period.month:
        return now.subtract(const Duration(days: 30));
      case _Period.year:
        return now.subtract(const Duration(days: 365));
    }
  }

  Future<void> _pickCustomFrom() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _customFrom ?? now.subtract(const Duration(days: 7)),
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      helpText: 'Show trends from',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: _primaryBlack,
              onPrimary: _creamBg,
              surface: _creamCardTop,
              onSurface: _textMain,
            ),
            dialogTheme: DialogThemeData(backgroundColor: _creamCardTop),
          ),
          child: child!,
        );
      },
    );

    if (selected == null) return;
    setState(() => _customFrom = selected);
  }

  @override
  Widget build(BuildContext context) {
    final logs = context.watch<HealthDataProvider>().logs;
    final cutoff = _cutoff();
    final filtered = logs.where((l) => l.timestamp.isAfter(cutoff)).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final weightLogs = filtered.where((l) => l.logType == 'WEIGHT').toList();
    final bpLogs = filtered
        .where((l) => l.logType == 'BLOOD_PRESSURE')
        .toList();
    final hrLogs = filtered.where((l) => l.logType == 'HEART_RATE').toList();

    // Stats calculations
    final weights = weightLogs
        .map((l) => double.tryParse(l.value) ?? 0.0)
        .toList();
    final avgWeight = weights.isEmpty
        ? '--'
        : (weights.reduce((a, b) => a + b) / weights.length).toStringAsFixed(1);

    final bpPairs = bpLogs.map((l) {
      final p = l.value.split('/');
      return [int.tryParse(p[0]) ?? 0, int.tryParse(p[1]) ?? 0];
    }).toList();

    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0.8, -0.9),
          radius: 1.2,
          colors: [_glowGold, _creamBg],
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _header(),
            SizedBox(height: 24),
            _SegmentedPeriod(
              value: _period,
              onChanged: (p) => setState(() {
                _period = p;
                _customFrom = null;
              }),
            ),
            if (_customFrom != null) ...[
              SizedBox(height: 12),
              _CustomDateChip(
                date: _customFrom!,
                onClear: () => setState(() => _customFrom = null),
              ),
            ],
            SizedBox(height: 24),
            _ChartCard(
              title: 'WEIGHT HISTORY',
              value: '$avgWeight kg',
              subtitle: 'Average Weight',
              child: _WeightLineChart(logs: weightLogs),
            ),
            SizedBox(height: 16),
            _ChartCard(
              title: 'BLOOD PRESSURE',
              value: bpPairs.isEmpty
                  ? '--'
                  : '${bpPairs.last[0]}/${bpPairs.last[1]}',
              subtitle: 'Latest Reading',
              child: _BPBarChart(logs: bpLogs),
            ),
            SizedBox(height: 16),
            _VitalRowCard(
              tileColor: _hrPink,
              tileIcon: Text('🫀', style: TextStyle(fontSize: 22)),
              title: 'Heart Rate',
              subtitle: hrLogs.isEmpty
                  ? '-- bpm'
                  : '${hrLogs.last.value} bpm (Latest)',
              statusLabel: _hrStatusLabel(hrLogs),
              statusColor: _hrStatusColor(hrLogs),
              range: _HeartRateRange(logs: hrLogs),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _header() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Trends',
            style: TextStyle(
              color: _textMain,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Analytics & Visual Insights',
            style: TextStyle(color: _textMuted, fontSize: 14),
          ),
        ],
      ),
      Tooltip(
        message: 'Pick start date',
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _pickCustomFrom,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _creamCardTop,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _surfaceBorder),
              boxShadow: AppGlobals.softShadow,
            ),
            child: Icon(
              Icons.calendar_month_outlined,
              color: _primaryBlack,
              size: 28,
            ),
          ),
        ),
      ),
    ],
  );
}

class _CustomDateChip extends StatelessWidget {
  final DateTime date;
  final VoidCallback onClear;
  const _CustomDateChip({required this.date, required this.onClear});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: _creamCardTop,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _surfaceBorder),
      boxShadow: AppGlobals.softShadow,
    ),
    child: Row(
      children: [
        Icon(Icons.date_range_outlined, color: _primaryBlack, size: 18),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Showing since ${_formatShortDate(date)}',
            style: TextStyle(
              color: _textMain,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextButton(
          onPressed: onClear,
          style: TextButton.styleFrom(
            foregroundColor: _textMuted,
            padding: EdgeInsets.symmetric(horizontal: 8),
            minimumSize: const Size(0, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text('Clear'),
        ),
      ],
    ),
  );
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_creamCardTop, _creamCard],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _surfaceBorder),
      boxShadow: AppGlobals.softShadow,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: _textMuted,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                color: _textMain,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text(
                subtitle,
                style: TextStyle(color: _textMuted, fontSize: 12),
              ),
            ),
          ],
        ),
        SizedBox(height: 24),
        SizedBox(height: 180, child: child),
      ],
    ),
  );
}

class _WeightLineChart extends StatelessWidget {
  final List<LogEntry> logs;
  const _WeightLineChart({required this.logs});

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return _ChartEmptyState(
        icon: Icons.monitor_weight_outlined,
        title: 'No weight data yet',
        subtitle: 'Log weight from Home to start seeing your trend.',
      );
    }

    final spots = logs.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), double.tryParse(e.value.value) ?? 0);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: _bottomDateTitles(logs),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: _primaryBlack,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(show: spots.length < 10),
            shadow: Shadow(
              color: _primaryBlack.withValues(alpha: 0.18),
              blurRadius: 10,
            ),
            belowBarData: BarAreaData(
              show: true,
              color: _primaryBlack.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }
}

class _BPBarChart extends StatelessWidget {
  final List<LogEntry> logs;
  const _BPBarChart({required this.logs});

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return _ChartEmptyState(
        icon: Icons.favorite_border,
        title: 'No BP readings yet',
        subtitle: 'Log blood pressure from Home to compare readings.',
      );
    }

    final items = logs.asMap().entries.map((e) {
      final p = e.value.value.split('/');
      final sys = double.tryParse(p[0]) ?? 0.0;
      final dia = double.tryParse(p.length > 1 ? p[1] : '0') ?? 0.0;
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: sys,
            color: _primaryBlack,
            width: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: dia,
            color: _tanButtonLifted,
            width: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        barGroups: items,
        maxY: 170,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 40,
          getDrawingHorizontalLine: (value) => FlLine(
            color: _surfaceBorder.withValues(alpha: 0.5),
            strokeWidth: 1,
          ),
        ),
        titlesData: _bottomDateTitles(logs),
        borderData: FlBorderData(show: false),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: 120,
              color: _vitalSuccess.withValues(alpha: 0.5),
              strokeWidth: 1.5,
              dashArray: [6, 5],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                style: TextStyle(
                  color: _vitalSuccess,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                labelResolver: (_) => 'SYS normal',
              ),
            ),
            HorizontalLine(
              y: 80,
              color: _tanButtonLifted.withValues(alpha: 0.8),
              strokeWidth: 1.5,
              dashArray: [6, 5],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.bottomRight,
                style: TextStyle(
                  color: _textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                labelResolver: (_) => 'DIA normal',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentedPeriod extends StatelessWidget {
  final _Period value;
  final ValueChanged<_Period> onChanged;
  const _SegmentedPeriod({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: _creamCardTop,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _surfaceBorder),
      boxShadow: AppGlobals.softShadow,
    ),
    child: Row(
      children: _Period.values.map((p) {
        final sel = p == value;
        return Expanded(
          child: InkWell(
            onTap: () => onChanged(p),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: sel ? _primaryBlack : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: sel
                    ? [
                        BoxShadow(
                          color: _primaryBlack.withValues(alpha: 0.18),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                p.name.toUpperCase(),
                style: TextStyle(
                  color: sel ? _creamBg : _textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    ),
  );
}

class _VitalRowCard extends StatelessWidget {
  final Color tileColor;
  final Widget tileIcon;
  final String title;
  final String subtitle;
  final String statusLabel;
  final Color statusColor;
  final Widget? range;
  const _VitalRowCard({
    required this.tileColor,
    required this.tileIcon,
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    required this.statusColor,
    this.range,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_creamCardTop, _creamCard],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _surfaceBorder),
      boxShadow: AppGlobals.softShadow,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: tileColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: tileColor.withValues(alpha: 0.28),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: tileIcon,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: _textMain,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: _textMuted, fontSize: 14),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  color: _creamBg,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        if (range != null) ...[SizedBox(height: 16), range!],
      ],
    ),
  );
}

class _HeartRateRange extends StatelessWidget {
  final List<LogEntry> logs;
  const _HeartRateRange({required this.logs});

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return Text(
        'Normal resting range guidance appears after your first HR log.',
        style: TextStyle(color: _textMuted, fontSize: 12),
      );
    }

    final bpm = int.tryParse(logs.last.value) ?? 0;
    final clamped = bpm.clamp(40, 140);
    final position = (clamped - 40) / 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  colors: [
                    _tanButtonLifted,
                    _vitalSuccess,
                    _vitalSuccess,
                    _tanButtonLifted,
                  ],
                  stops: const [0, 0.2, 0.6, 1],
                ),
              ),
            ),
            FractionallySizedBox(
              widthFactor: position,
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: _primaryBlack,
                    shape: BoxShape.circle,
                    border: Border.all(color: _creamCardTop, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryBlack.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('40', style: TextStyle(color: _textMuted, fontSize: 11)),
            Text(
              '60-100 normal',
              style: TextStyle(
                color: _vitalSuccess,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('140', style: TextStyle(color: _textMuted, fontSize: 11)),
          ],
        ),
      ],
    );
  }
}

class _ChartEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _ChartEmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: _tanButtonLifted,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _surfaceBorder),
          ),
          child: Icon(icon, color: _primaryBlack, size: 22),
        ),
        SizedBox(height: 10),
        Text(
          title,
          style: TextStyle(
            color: _textMain,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(color: _textMuted, fontSize: 12),
        ),
      ],
    ),
  );
}

FlTitlesData _bottomDateTitles(List<LogEntry> logs) {
  final interval = logs.length <= 4 ? 1.0 : (logs.length / 4).ceilToDouble();

  return FlTitlesData(
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 30,
        interval: interval,
        getTitlesWidget: (value, meta) {
          final index = value.round();
          if (index < 0 || index >= logs.length || value != index) {
            return const SizedBox.shrink();
          }
          return SideTitleWidget(
            meta: meta,
            space: 8,
            child: Text(
              _formatTinyDate(logs[index].timestamp),
              style: TextStyle(
                color: _textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ),
    ),
  );
}

String _hrStatusLabel(List<LogEntry> logs) {
  if (logs.isEmpty) return 'ADD';
  final bpm = int.tryParse(logs.last.value);
  if (bpm == null) return 'CHECK';
  if (bpm < 60 || bpm > 100) return 'WATCH';
  return 'NORMAL';
}

Color _hrStatusColor(List<LogEntry> logs) {
  if (logs.isEmpty) return _textMuted;
  final bpm = int.tryParse(logs.last.value);
  if (bpm == null || bpm < 60 || bpm > 100) {
    return const Color(0xFFE8A317);
  }
  return _vitalSuccess;
}

String _formatShortDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

String _formatTinyDate(DateTime date) {
  const months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
  return '${months[date.month - 1]} ${date.day}';
}
