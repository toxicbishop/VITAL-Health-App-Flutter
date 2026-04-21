import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models.dart';
import '../providers/health_data_provider.dart';

const _creamBg = Color(0xFFF5F3EC);
const _creamCard = Color(0xFFFAF8F2);
const _tanButton = Color(0xFFDBD5C4);
const _textMain = Color(0xFF0D0C0A);
const _textMuted = Color(0xFF6B6659);
const _primaryBlack = Color(0xFF000000);
const _vitalSuccess = Color(0xFF27734A);
const _vitalError = Color(0xFFB00020);
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _customFrom ?? _cutoff(),
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      helpText: 'Select start date',
      confirmText: 'OK',
      cancelText: 'Clear',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _primaryBlack,
            onPrimary: _creamBg,
            surface: _creamCard,
            onSurface: _textMain,
          ),
          datePickerTheme: DatePickerThemeData(
            backgroundColor: _creamCard,
            headerBackgroundColor: _creamCard,
            headerForegroundColor: _textMain,
            weekdayStyle: const TextStyle(color: _textMuted),
            dayStyle: const TextStyle(color: _textMain),
            todayForegroundColor:
                WidgetStateProperty.all<Color>(_primaryBlack),
            todayBorder: const BorderSide(color: _primaryBlack),
            dayForegroundColor: WidgetStateProperty.resolveWith(
                (s) => s.contains(WidgetState.selected)
                    ? _creamBg
                    : _textMain),
            dayBackgroundColor: WidgetStateProperty.resolveWith(
                (s) => s.contains(WidgetState.selected)
                    ? _primaryBlack
                    : Colors.transparent),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: _primaryBlack),
          ),
        ),
        child: child!,
      ),
    );
    if (!mounted) return;
    setState(() {
      _customFrom = picked; // null when user taps "Clear"
    });
  }

  @override
  Widget build(BuildContext context) {
    final logs = context.watch<HealthDataProvider>().logs;
    final cutoff = _cutoff();
    final filtered = logs.where((l) => l.timestamp.isAfter(cutoff)).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final weightLogs = filtered.where((l) => l.logType == 'WEIGHT').toList();
    final bpLogs =
        filtered.where((l) => l.logType == 'BLOOD_PRESSURE').toList();
    final hrLogs = filtered.where((l) => l.logType == 'HEART_RATE').toList();

    final weights = weightLogs
        .map((l) => double.tryParse(l.value))
        .whereType<double>()
        .toList();
    final avgWeight = weights.isEmpty
        ? '--'
        : (weights.reduce((a, b) => a + b) / weights.length).toStringAsFixed(1);
    String weightDelta = '--';
    if (weights.length >= 2) {
      final half = weights.length ~/ 2;
      final first = weights.take(half);
      final second = weights.skip(half);
      final diff = (second.reduce((a, b) => a + b) / second.length) -
          (first.reduce((a, b) => a + b) / first.length);
      weightDelta =
          '${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(1)}';
    }

    final bpPairs = bpLogs
        .map((l) {
          final p = l.value.split('/');
          if (p.length != 2) return null;
          final s = int.tryParse(p[0]);
          final d = int.tryParse(p[1]);
          if (s == null || d == null) return null;
          return [s, d];
        })
        .whereType<List<int>>()
        .toList();
    final avgSys = bpPairs.isEmpty
        ? null
        : (bpPairs.map((p) => p[0]).reduce((a, b) => a + b) / bpPairs.length)
            .round();
    final avgDia = bpPairs.isEmpty
        ? null
        : (bpPairs.map((p) => p[1]).reduce((a, b) => a + b) / bpPairs.length)
            .round();
    final avgBpStr = (avgSys != null && avgDia != null)
        ? '$avgSys/$avgDia mmHg'
        : '-- mmHg';
    String bpStatus;
    Color bpStatusColor;
    if (avgSys == null) {
      bpStatus = 'NO DATA';
      bpStatusColor = _textMuted;
    } else if (avgSys < 120 && (avgDia ?? 0) < 80) {
      bpStatus = 'NORMAL';
      bpStatusColor = _vitalSuccess;
    } else if (avgSys < 130) {
      bpStatus = 'ELEVATED';
      bpStatusColor = const Color(0xFFE2B93D);
    } else {
      bpStatus = 'HIGH';
      bpStatusColor = _vitalError;
    }

    final hrValues =
        hrLogs.map((l) => int.tryParse(l.value)).whereType<int>().toList();
    final avgHr = hrValues.isEmpty
        ? null
        : (hrValues.reduce((a, b) => a + b) / hrValues.length).round();
    final minHr = hrValues.isEmpty
        ? null
        : hrValues.reduce((a, b) => a < b ? a : b);
    final maxHr = hrValues.isEmpty
        ? null
        : hrValues.reduce((a, b) => a > b ? a : b);
    String hrStatus;
    Color hrStatusColor;
    if (avgHr == null) {
      hrStatus = 'NO DATA';
      hrStatusColor = _textMuted;
    } else if (avgHr < 60) {
      hrStatus = 'LOW';
      hrStatusColor = const Color(0xFF3B82F6);
    } else if (avgHr <= 100) {
      hrStatus = 'NORMAL';
      hrStatusColor = _vitalSuccess;
    } else {
      hrStatus = 'HIGH';
      hrStatusColor = _vitalError;
    }

    final subtitle = _customFrom != null
        ? 'From ${_fmtShort(_customFrom!)}'
        : 'Analytics & Insights';

    return Container(
      color: _creamBg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Health Trends',
                          style: TextStyle(
                            color: _textMain,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          )),
                      Text(subtitle,
                          style: const TextStyle(
                              color: _textMuted, fontSize: 14)),
                    ],
                  ),
                ),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _tanButton),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.calendar_today,
                        color: _primaryBlack, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SegmentedPeriod(
              value: _period,
              onChanged: (p) => setState(() {
                _period = p;
                _customFrom = null;
              }),
            ),
            const SizedBox(height: 24),
            _WeightTrendCard(
              avg: avgWeight,
              delta: weightDelta,
              weights: weights,
              count: weightLogs.length,
            ),
            const SizedBox(height: 16),
            _VitalRowCard(
              tileColor: _primaryBlack,
              tileIcon: const Icon(Icons.favorite_border, color: _creamBg),
              title: 'Blood Pressure',
              subtitle: 'Average: $avgBpStr',
              statusLabel: bpStatus,
              statusColor: bpStatusColor,
            ),
            const SizedBox(height: 16),
            _VitalRowCard(
              tileColor: _hrPink,
              tileIcon: const Text('🫀', style: TextStyle(fontSize: 22)),
              title: 'Heart Rate',
              subtitle: avgHr != null ? 'Avg: $avgHr bpm' : '-- bpm',
              extraLine: (minHr != null && maxHr != null)
                  ? 'Range: $minHr–$maxHr bpm'
                  : null,
              statusLabel: hrStatus,
              statusColor: hrStatusColor,
            ),
            const SizedBox(height: 24),
            _InsightsSection(
              bpPairs: bpPairs,
              bpLogs: bpLogs,
              weights: weights,
              hrValues: hrValues,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  static String _fmtShort(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

class _SegmentedPeriod extends StatelessWidget {
  final _Period value;
  final ValueChanged<_Period> onChanged;
  const _SegmentedPeriod({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _creamCard,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: _Period.values.map((p) {
          final selected = p == value;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => onChanged(p),
              child: Container(
                decoration: BoxDecoration(
                  color: selected ? _primaryBlack : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                child: Text(
                  _label(p),
                  style: TextStyle(
                    color: selected ? _creamBg : _textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  static String _label(_Period p) {
    switch (p) {
      case _Period.week:
        return 'Week';
      case _Period.month:
        return 'Month';
      case _Period.year:
        return 'Year';
    }
  }
}

class _WeightTrendCard extends StatelessWidget {
  final String avg;
  final String delta; // e.g. '-1.2' / '+0.5' / '--'
  final List<double> weights;
  final int count;
  const _WeightTrendCard({
    required this.avg,
    required this.delta,
    required this.weights,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final hasDelta = delta != '--';
    final deltaColor = hasDelta && delta.startsWith('-')
        ? _vitalSuccess
        : _vitalError;
    return Container(
      decoration: BoxDecoration(
        color: _creamCard,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('WEIGHT TREND',
                        style: TextStyle(
                          color: _textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        )),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('$avg kg',
                            style: const TextStyle(
                              color: _textMain,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            )),
                        const SizedBox(width: 8),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Text('Average',
                              style: TextStyle(
                                  color: _textMuted, fontSize: 14)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (hasDelta)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: deltaColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('$delta kg',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      )),
                ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 40,
            child: weights.isEmpty
                ? const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('No weight data for this period',
                        style:
                            TextStyle(color: _textMuted, fontSize: 12)),
                  )
                : _MiniBars(values: _lastN(weights, 7)),
          ),
          const SizedBox(height: 8),
          Text('$count entries',
              style: const TextStyle(color: _textMuted, fontSize: 12)),
        ],
      ),
    );
  }

  static List<double> _lastN(List<double> src, int n) {
    if (src.length <= n) return src;
    return src.sublist(src.length - n);
  }
}

class _MiniBars extends StatelessWidget {
  final List<double> values;
  const _MiniBars({required this.values});

  @override
  Widget build(BuildContext context) {
    final max = values.reduce((a, b) => a > b ? a : b);
    final min = values.reduce((a, b) => a < b ? a : b);
    final range = (max - min) > 0 ? (max - min) : 1.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: values.map((v) {
        final frac = ((v - min) / range).clamp(0.0, 1.0);
        final h = 8 + frac * 32;
        return Container(
          width: 8,
          height: h,
          decoration: BoxDecoration(
            color: _primaryBlack,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }).toList(),
    );
  }
}

class _VitalRowCard extends StatelessWidget {
  final Color tileColor;
  final Widget tileIcon;
  final String title;
  final String subtitle;
  final String? extraLine;
  final String statusLabel;
  final Color statusColor;
  const _VitalRowCard({
    required this.tileColor,
    required this.tileIcon,
    required this.title,
    required this.subtitle,
    this.extraLine,
    required this.statusLabel,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: _creamCard,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: tileColor,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: tileIcon,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        color: _textMain,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      )),
                  Text(subtitle,
                      style:
                          const TextStyle(color: _textMuted, fontSize: 14)),
                  if (extraLine != null)
                    Text(extraLine!,
                        style: const TextStyle(
                            color: _textMuted, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('• $statusLabel',
                  style: const TextStyle(
                    color: _creamBg,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ],
        ),
      );
}

class _InsightsSection extends StatelessWidget {
  final List<List<int>> bpPairs;
  final List<LogEntry> bpLogs;
  final List<double> weights;
  final List<int> hrValues;
  const _InsightsSection({
    required this.bpPairs,
    required this.bpLogs,
    required this.weights,
    required this.hrValues,
  });

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[];

    if (bpPairs.length >= 2) {
      final morningSys = bpLogs
          .where((l) =>
              l.timestamp.hour >= 6 && l.timestamp.hour <= 11)
          .map((l) => int.tryParse(l.value.split('/').first))
          .whereType<int>()
          .toList();
      final eveningSys = bpLogs
          .where((l) =>
              l.timestamp.hour >= 18 && l.timestamp.hour <= 23)
          .map((l) => int.tryParse(l.value.split('/').first))
          .whereType<int>()
          .toList();
      String body;
      if (morningSys.isNotEmpty && eveningSys.isNotEmpty) {
        final diff = morningSys.reduce((a, b) => a + b) / morningSys.length -
            eveningSys.reduce((a, b) => a + b) / eveningSys.length;
        if (diff > 0) {
          body =
              'Systolic readings are ${diff.toInt()} mmHg higher in the morning versus evening.';
        } else {
          body =
              'Evening readings are ${(-diff).toInt()} mmHg higher than morning readings.';
        }
      } else {
        body = 'Log BP at different times of day to see patterns.';
      }
      cards.add(_InsightCard(
        icon: Icons.info_outline,
        title: 'BLOOD PRESSURE PATTERN',
        body: body,
        iconTint: _primaryBlack,
      ));
    }

    if (weights.length >= 2) {
      final trend = weights.last - weights.first;
      final dir = trend < 0 ? 'downward' : 'upward';
      cards.add(_InsightCard(
        icon: Icons.warning_amber_outlined,
        title: 'WEIGHT CORRELATION',
        body:
            'Weight shows a $dir trend of ${trend.abs().toStringAsFixed(1)} kg over this period.',
        iconTint: trend < 0 ? _vitalSuccess : _vitalError,
      ));
    }

    if (hrValues.length >= 2) {
      final trend = hrValues.last - hrValues.first;
      final dir = trend < 0 ? 'decreasing' : 'increasing';
      cards.add(_InsightCard(
        icon: Icons.info_outline,
        title: 'HEART RATE TREND',
        body:
            'Average HR $dir by ${trend.abs()} bpm over this period.',
        iconTint: _hrPink,
      ));
    }

    if (cards.isEmpty) {
      cards.add(Container(
        decoration: BoxDecoration(
          color: _creamCard,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: const Text('Log more data to see health insights!',
            style: TextStyle(color: _textMuted, fontSize: 14)),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text('HEALTH INSIGHTS',
              style: TextStyle(
                color: _textMuted,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              )),
        ),
        for (var i = 0; i < cards.length; i++) ...[
          cards[i],
          if (i != cards.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color iconTint;
  const _InsightCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.iconTint,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: _creamCard,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(icon, color: iconTint, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        color: _textMain,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      )),
                  const SizedBox(height: 8),
                  Text('• $body',
                      style: const TextStyle(
                          color: _textMuted, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      );
}
