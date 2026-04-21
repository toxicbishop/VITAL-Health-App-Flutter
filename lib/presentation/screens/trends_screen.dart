import 'package:flutter/material.dart';
import '../../core/app_globals.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models.dart';
import '../providers/health_data_provider.dart';

Color get _creamBg => AppGlobals.creamBg;
Color get _creamCard => AppGlobals.creamCard;
Color get _tanButton => AppGlobals.tanButton;
Color get _textMain => AppGlobals.textMain;
Color get _textMuted => AppGlobals.textMuted;
Color get _primaryBlack => AppGlobals.primaryBlack;
Color get _vitalSuccess => AppGlobals.vitalSuccess;
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

  @override
  Widget build(BuildContext context) {
    final logs = context.watch<HealthDataProvider>().logs;
    final cutoff = _cutoff();
    final filtered = logs.where((l) => l.timestamp.isAfter(cutoff)).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final weightLogs = filtered.where((l) => l.logType == 'WEIGHT').toList();
    final bpLogs = filtered.where((l) => l.logType == 'BLOOD_PRESSURE').toList();
    final hrLogs = filtered.where((l) => l.logType == 'HEART_RATE').toList();

    // Stats calculations 
    final weights = weightLogs.map((l) => double.tryParse(l.value) ?? 0.0).toList();
    final avgWeight = weights.isEmpty ? '--' : (weights.reduce((a, b) => a + b) / weights.length).toStringAsFixed(1);

    final bpPairs = bpLogs.map((l) {
      final p = l.value.split('/');
      return [int.tryParse(p[0]) ?? 0, int.tryParse(p[1]) ?? 0];
    }).toList();

    return Container(
      color: _creamBg,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _header(),
            SizedBox(height: 24),
            _SegmentedPeriod(
              value: _period,
              onChanged: (p) => setState(() { _period = p; _customFrom = null; }),
            ),
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
              value: bpPairs.isEmpty ? '--' : '${bpPairs.last[0]}/${bpPairs.last[1]}',
              subtitle: 'Latest Reading',
              child: _BPBarChart(logs: bpLogs),
            ),
            SizedBox(height: 16),
            _VitalRowCard(
              tileColor: _hrPink,
              tileIcon: Text('🫀', style: TextStyle(fontSize: 22)),
              title: 'Heart Rate',
              subtitle: hrLogs.isEmpty ? '-- bpm' : '${hrLogs.last.value} bpm (Latest)',
              statusLabel: 'TRACKED',
              statusColor: _vitalSuccess,
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
          Text('Health Trends', style: TextStyle(color: _textMain, fontSize: 28, fontWeight: FontWeight.bold)),
          Text('Analytics & Visual Insights', style: TextStyle(color: _textMuted, fontSize: 14)),
        ],
      ),
      Icon(Icons.analytics_outlined, color: _primaryBlack, size: 32),
    ],
  );
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Widget child;

  const _ChartCard({required this.title, required this.value, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(color: _creamCard, borderRadius: BorderRadius.circular(16)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: _textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value, style: TextStyle(color: _textMain, fontSize: 26, fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            Padding(padding: EdgeInsets.only(bottom: 4), child: Text(subtitle, style: TextStyle(color: _textMuted, fontSize: 12))),
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
    if (logs.isEmpty) return Center(child: Text('No data', style: TextStyle(color: _textMuted)));
    
    final spots = logs.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), double.tryParse(e.value.value) ?? 0);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: _primaryBlack,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(show: spots.length < 10),
            belowBarData: BarAreaData(show: true, color: _primaryBlack.withValues(alpha: 0.05)),
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
    if (logs.isEmpty) return Center(child: Text('No data', style: TextStyle(color: _textMuted)));
    
    final items = logs.asMap().entries.map((e) {
      final p = e.value.value.split('/');
      final sys = double.tryParse(p[0]) ?? 0.0;
      final dia = double.tryParse(p.length > 1 ? p[1] : '0') ?? 0.0;
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(toY: sys, color: _primaryBlack, width: 8, borderRadius: BorderRadius.circular(2)),
          BarChartRodData(toY: dia, color: _tanButton, width: 8, borderRadius: BorderRadius.circular(2)),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        barGroups: items,
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
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
    decoration: BoxDecoration(color: _creamCard, borderRadius: BorderRadius.circular(12)),
    child: Row(
      children: _Period.values.map((p) {
        final sel = p == value;
        return Expanded(
          child: InkWell(
            onTap: () => onChanged(p),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: sel ? _primaryBlack : Colors.transparent, borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
              child: Text(p.name.toUpperCase(), style: TextStyle(color: sel ? _creamBg : _textMuted, fontSize: 12, fontWeight: FontWeight.bold)),
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
  const _VitalRowCard({required this.tileColor, required this.tileIcon, required this.title, required this.subtitle, required this.statusLabel, required this.statusColor});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(color: _creamCard, borderRadius: BorderRadius.circular(16)),
    child: Row(
      children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: tileColor, borderRadius: BorderRadius.circular(12)), alignment: Alignment.center, child: tileIcon),
        SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(color: _textMain, fontWeight: FontWeight.bold, fontSize: 16)),
          Text(subtitle, style: TextStyle(color: _textMuted, fontSize: 14)),
        ])),
        Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(6)), child: Text(statusLabel, style: TextStyle(color: _creamBg, fontSize: 10, fontWeight: FontWeight.bold))),
      ],
    ),
  );
}
