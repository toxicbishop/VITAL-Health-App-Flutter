import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/models.dart';
import '../providers/app_config_provider.dart';
import '../providers/health_data_provider.dart';
import 'journal_screen.dart';
import 'meds_screen.dart';
import 'settings_screen.dart';
import 'trends_screen.dart';

// ---------------------------------------------------------------------------
// Palette — mirrors VITAL-Health-App-Kotlin `Color.kt` 1:1 (light mode).
// ---------------------------------------------------------------------------
const _creamBg = Color(0xFFF5F3EC);
const _creamCard = Color(0xFFFAF8F2);
const _tanButton = Color(0xFFDBD5C4);
const _textMain = Color(0xFF0D0C0A);
const _textMuted = Color(0xFF6B6659);
const _primaryBlack = Color(0xFF000000);
const _vitalSuccess = Color(0xFF27734A);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _tab = 0; // 0 HOME, 1 MEDS, 2 TRENDS, 3 JOURNAL, 4 SETTINGS
  bool _showInitialOptions = true;
  bool _medTaken = false;
  final Set<String> _dismissedAlerts = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_showInitialOptions) _openInitialOptions();
    });
  }

  void _openInitialOptions() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _creamCard,
        title: const Text('Log Vitals', style: TextStyle(color: _textMain)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogButton(
              'Log Weight Only',
              fill: _tanButton,
              onTap: () {
                Navigator.pop(ctx);
                _showAddLog(initialType: 'WEIGHT', both: false);
              },
            ),
            const SizedBox(height: 12),
            _dialogButton(
              'Log BP Only',
              fill: _tanButton,
              onTap: () {
                Navigator.pop(ctx);
                _showAddLog(initialType: 'BLOOD_PRESSURE', both: false);
              },
            ),
            const SizedBox(height: 12),
            _dialogButton(
              'Log Both',
              fill: _primaryBlack,
              fg: _creamBg,
              bold: true,
              onTap: () {
                Navigator.pop(ctx);
                _showAddLog(initialType: 'WEIGHT', both: true);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: _textMuted)),
          ),
        ],
      ),
    ).then((_) => setState(() => _showInitialOptions = false));
  }

  void _showAddLog({required String initialType, required bool both}) {
    showDialog(
      context: context,
      builder: (_) => _AddLogDialog(initialType: initialType, both: both),
    );
  }

  void _showMoodDialog() =>
      showDialog(context: context, builder: (_) => const _MoodLogDialog());

  void _showAddMedDialog() =>
      showDialog(context: context, builder: (_) => const _AddMedicationDialog());

  void _showHrDialog() =>
      showDialog(context: context, builder: (_) => const _HeartRateDialog());

  void _showAppointmentDialog() =>
      showDialog(context: context, builder: (_) => const _AppointmentDialog());

  void _showMonthlySummary(List<LogEntry> logs) => showDialog(
        context: context,
        builder: (_) => _MonthlySummaryDialog(logs: logs),
      );

  void _logout() async {
    await context.read<AppConfigProvider>().reset();
  }

  @override
  Widget build(BuildContext context) {
    final logs = context.watch<HealthDataProvider>().logs;
    final userName = context.select<AppConfigProvider, String>((p) => p.userName);

    return Scaffold(
      backgroundColor: _creamBg,
      bottomNavigationBar: _BottomNav(
        current: _tab,
        onChanged: (i) => setState(() => _tab = i),
      ),
      body: SafeArea(
        child: _buildTab(logs, userName),
      ),
    );
  }

  Widget _buildTab(List<LogEntry> logs, String userName) {
    switch (_tab) {
      case 1:
        return const MedsScreen();
      case 2:
        return const TrendsScreen();
      case 3:
        return const JournalScreen();
      case 4:
        return const SettingsScreen();
      default:
        return _HomeTab(
          logs: logs,
          userName: userName,
          medTaken: _medTaken,
          dismissedAlerts: _dismissedAlerts,
          onDismissAlert: (k) => setState(() => _dismissedAlerts.add(k)),
          onMarkMedTaken: () => setState(() => _medTaken = true),
          onLogout: _logout,
          onLogVitalsTile: () =>
              _showAddLog(initialType: 'WEIGHT', both: false),
          onLogBpTile: () =>
              _showAddLog(initialType: 'BLOOD_PRESSURE', both: false),
          onLogHr: _showHrDialog,
          onLogMood: _showMoodDialog,
          onAddMed: _showAddMedDialog,
          onAddAppointment: _showAppointmentDialog,
          onMonthlySummary: () => _showMonthlySummary(logs),
          onExportPdf: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('PDF export not yet implemented.'),
            ));
          },
        );
    }
  }
}

// ---------------------------------------------------------------------------
// HOME TAB
// ---------------------------------------------------------------------------
class _HomeTab extends StatelessWidget {
  final List<LogEntry> logs;
  final String userName;
  final bool medTaken;
  final Set<String> dismissedAlerts;
  final ValueChanged<String> onDismissAlert;
  final VoidCallback onMarkMedTaken;
  final VoidCallback onLogout;
  final VoidCallback onLogVitalsTile;
  final VoidCallback onLogBpTile;
  final VoidCallback onLogHr;
  final VoidCallback onLogMood;
  final VoidCallback onAddMed;
  final VoidCallback onAddAppointment;
  final VoidCallback onMonthlySummary;
  final VoidCallback onExportPdf;

  const _HomeTab({
    required this.logs,
    required this.userName,
    required this.medTaken,
    required this.dismissedAlerts,
    required this.onDismissAlert,
    required this.onMarkMedTaken,
    required this.onLogout,
    required this.onLogVitalsTile,
    required this.onLogBpTile,
    required this.onLogHr,
    required this.onLogMood,
    required this.onAddMed,
    required this.onAddAppointment,
    required this.onMonthlySummary,
    required this.onExportPdf,
  });

  @override
  Widget build(BuildContext context) {
    final todayStr = _formatDate(DateTime.now());
    final todayMidnight = DateTime.now().copyWith(
      hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0,
    );
    final todayMood = logs
        .where((l) => l.logType == 'MOOD' && l.timestamp.isAfter(todayMidnight))
        .fold<LogEntry?>(null, (prev, l) {
      if (prev == null || l.timestamp.isAfter(prev.timestamp)) return l;
      return prev;
    });
    final latestMed = _latest(logs, 'MEDICATION');

    final recentBp = logs.where((l) =>
        l.logType == 'BLOOD_PRESSURE' &&
        DateTime.now().difference(l.timestamp).inDays < 3);
    final elevatedBpDays = recentBp
        .map((l) => int.tryParse(l.value.split('/').first))
        .where((v) => v != null && v >= 130)
        .length;

    final lastWeight = _latest(logs, 'WEIGHT')?.value ?? '--';
    final lastBp = _latest(logs, 'BLOOD_PRESSURE')?.value ?? '--';
    final lastHr = _latest(logs, 'HEART_RATE')?.value ?? '--';

    final nextAppointment = _latest(logs, 'APPOINTMENT');

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
                    const Text(
                      'Vital Dashboard',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _textMain,
                      ),
                    ),
                    Text(
                      todayStr,
                      style: const TextStyle(color: _textMuted, fontSize: 14),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.exit_to_app, color: _textMuted),
                onPressed: onLogout,
                tooltip: 'Logout',
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (elevatedBpDays >= 2 && !dismissedAlerts.contains('bp')) ...[
            _alertCard(
              emoji: '⚠️',
              title: 'BP Alert',
              subtitle:
                  'Systolic ≥130 in $elevatedBpDays of last 3 logs',
              bg: const Color(0xFF3D1F1F),
              titleColor: const Color(0xFFFF6B6B),
              subtitleColor: const Color(0xFFFFAAAA),
              onDismiss: () => onDismissAlert('bp'),
            ),
            const SizedBox(height: 24),
          ],
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'WEIGHT',
                  icon: Icons.person_outline,
                  value: '$lastWeight kg',
                  onLog: onLogVitalsTile,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'BP',
                  icon: Icons.favorite_border,
                  value: lastBp,
                  onLog: onLogBpTile,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'HR',
                  icon: Icons.monitor_heart_outlined,
                  value: lastHr == '--' ? '--' : '$lastHr bpm',
                  onLog: onLogHr,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _Section(
            title: 'WELL-BEING',
            child: _CardContainer(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _iconTile(Icons.sentiment_satisfied_alt_outlined),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Mood',
                              style: TextStyle(
                                  color: _textMain,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16)),
                          Text(
                            todayMood != null
                                ? 'Today: ${todayMood.value}'
                                : 'No mood logged today',
                            style: const TextStyle(
                                color: _textMuted, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    _solidBtn('+ Log', onTap: onLogMood),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _Section(
            title: 'MEDICATION',
            child: _CardContainer(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _iconTile(Icons.shopping_bag_outlined),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('Active Prescriptions',
                                      style: TextStyle(
                                          color: _textMain,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16)),
                                  const SizedBox(width: 8),
                                  _activeBadge(logs),
                                ],
                              ),
                              Text(
                                latestMed != null
                                    ? '${latestMed.value} • ${latestMed.notes ?? ""}'
                                    : 'Prenatal Vitamin • 8:00 AM',
                                style: const TextStyle(
                                    color: _textMuted, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _solidBtn(
                            medTaken ? '✓ Taken' : 'Mark as Taken',
                            onTap: medTaken ? null : onMarkMedTaken,
                            fill: medTaken ? _vitalSuccess : _primaryBlack,
                            bold: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _solidBtn('+ Add',
                            onTap: onAddMed, fill: _tanButton, fg: _textMain),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _Section(
            title: 'CLINICAL REPORTS',
            child: _CardContainer(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _listRow(
                      icon: Icons.info_outline,
                      label: 'Monthly Health Summary',
                      onTap: onMonthlySummary,
                    ),
                    const Divider(color: _creamBg),
                    _listRow(
                      icon: Icons.picture_as_pdf_outlined,
                      label: 'Export Clinical Data (PDF)',
                      onTap: onExportPdf,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _Section(
            title: 'APPOINTMENTS',
            child: _CardContainer(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _iconTile(Icons.calendar_today),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Doctor Visits',
                              style: TextStyle(
                                  color: _textMain,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16)),
                          Text(
                            nextAppointment != null
                                ? '${nextAppointment.value} • ${nextAppointment.notes ?? ""}'
                                : 'No upcoming visits',
                            style: const TextStyle(
                                color: _textMuted, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    _solidBtn('+ Add', onTap: onAddAppointment, bold: true),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _alertCard({
    required String emoji,
    required String title,
    required String subtitle,
    required Color bg,
    required Color titleColor,
    required Color subtitleColor,
    required VoidCallback onDismiss,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: titleColor, fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style:
                          TextStyle(color: subtitleColor, fontSize: 13)),
                ],
              ),
            ),
            IconButton(
              onPressed: onDismiss,
              icon: Icon(Icons.close, color: titleColor),
            ),
          ],
        ),
      );

  Widget _iconTile(IconData icon) => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _primaryBlack,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: _creamBg),
      );

  Widget _activeBadge(List<LogEntry> logs) {
    final medCount = logs.where((l) => l.logType == 'MEDICATION').length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _creamBg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${medCount > 0 ? medCount : 1} Active',
        style: const TextStyle(color: _textMuted, fontSize: 10),
      ),
    );
  }

  Widget _solidBtn(
    String label, {
    VoidCallback? onTap,
    Color fill = _primaryBlack,
    Color fg = _creamBg,
    bool bold = false,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: fill,
        foregroundColor: fg,
        disabledBackgroundColor: fill,
        disabledForegroundColor: fg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      child: Text(
        label,
        style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal),
      ),
    );
  }

  Widget _listRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) =>
      InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(icon, color: _textMuted),
              const SizedBox(width: 16),
              Expanded(
                  child:
                      Text(label, style: const TextStyle(color: _textMain))),
              const Icon(Icons.keyboard_arrow_right, color: _textMuted),
            ],
          ),
        ),
      );
}

// ---------------------------------------------------------------------------
// SHARED COMPONENTS
// ---------------------------------------------------------------------------
class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: _textMuted,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _CardContainer extends StatelessWidget {
  final Widget child;
  const _CardContainer({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: _creamCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      );
}

class _MetricCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final VoidCallback onLog;
  const _MetricCard({
    required this.title,
    required this.icon,
    required this.value,
    required this.onLog,
  });

  @override
  Widget build(BuildContext context) => _CardContainer(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: _primaryBlack),
                  Text(title,
                      style: const TextStyle(
                          color: _textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Text(value,
                  style: const TextStyle(color: _textMain, fontSize: 14)),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onLog,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _textMain,
                  side: const BorderSide(color: _tanButton),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  minimumSize: const Size.fromHeight(36),
                ),
                child: const Text('Log Entry',
                    style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
      );
}

class _BottomNav extends StatelessWidget {
  final int current;
  final ValueChanged<int> onChanged;
  const _BottomNav({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) => NavigationBar(
        selectedIndex: current,
        onDestinationSelected: onChanged,
        backgroundColor: _creamCard,
        indicatorColor: _tanButton,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home, color: _textMuted),
              selectedIcon: Icon(Icons.home, color: _primaryBlack),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.add_circle_outline, color: _textMuted),
              selectedIcon:
                  Icon(Icons.add_circle_outline, color: _primaryBlack),
              label: 'Meds'),
          NavigationDestination(
              icon: Icon(Icons.calendar_today, color: _textMuted),
              selectedIcon:
                  Icon(Icons.calendar_today, color: _primaryBlack),
              label: 'Trends'),
          NavigationDestination(
              icon: Icon(Icons.edit_outlined, color: _textMuted),
              selectedIcon: Icon(Icons.edit_outlined, color: _primaryBlack),
              label: 'Journal'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined, color: _textMuted),
              selectedIcon:
                  Icon(Icons.settings_outlined, color: _primaryBlack),
              label: 'Settings'),
        ],
      );
}

class _ComingSoon extends StatelessWidget {
  final String title;
  const _ComingSoon({required this.title});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _textMain)),
            const SizedBox(height: 8),
            const Text('Coming soon',
                style: TextStyle(color: _textMuted, fontSize: 14)),
          ],
        ),
      );
}

// ---------------------------------------------------------------------------
// DIALOGS
// ---------------------------------------------------------------------------
class _AddLogDialog extends StatefulWidget {
  final String initialType;
  final bool both;
  const _AddLogDialog({required this.initialType, required this.both});

  @override
  State<_AddLogDialog> createState() => _AddLogDialogState();
}

class _AddLogDialogState extends State<_AddLogDialog> {
  final _weight = TextEditingController();
  final _sys = TextEditingController();
  final _dia = TextEditingController();
  final _notes = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _weight.dispose();
    _sys.dispose();
    _dia.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final provider = context.read<HealthDataProvider>();
    final notes = _notes.text.trim().isEmpty ? null : _notes.text.trim();
    setState(() => _saving = true);
    bool ok = false;
    if (widget.both) {
      final w = double.tryParse(_weight.text);
      final s = int.tryParse(_sys.text);
      final d = int.tryParse(_dia.text);
      if (w != null && s != null && d != null) {
        ok = await provider.logBoth(w, s, d, notes: notes);
      }
    } else if (widget.initialType == 'BLOOD_PRESSURE') {
      final s = int.tryParse(_sys.text);
      final d = int.tryParse(_dia.text);
      if (s != null && d != null) {
        ok = await provider.logBP(s, d, notes: notes);
      }
    } else {
      final w = double.tryParse(_weight.text);
      if (w != null) ok = await provider.logWeight(w, notes: notes);
    }
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: ok ? _vitalSuccess : Colors.red,
      content: Text(ok ? 'Saved to Google Sheet.' : 'Save failed.'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final showWeight = widget.both || widget.initialType == 'WEIGHT';
    final showBp = widget.both || widget.initialType == 'BLOOD_PRESSURE';
    return AlertDialog(
      backgroundColor: _creamCard,
      title: Text(
        widget.both ? 'Log Both (Weight & BP)' : 'Add Health Log',
        style: const TextStyle(color: _textMain),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!widget.both)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Type: ${widget.initialType.replaceAll('_', ' ')}',
                style: const TextStyle(color: _textMuted),
              ),
            ),
          if (showWeight)
            _field(
              controller: _weight,
              label: 'Weight (kg)',
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'^\d{0,3}(\.\d{0,2})?')),
              ],
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          if (showBp) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _field(
                    controller: _sys,
                    label: 'Systolic',
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    keyboardType: TextInputType.number,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('/',
                      style: TextStyle(
                          color: _textMuted,
                          fontSize: 24,
                          fontWeight: FontWeight.w500)),
                ),
                Expanded(
                  child: _field(
                    controller: _dia,
                    label: 'Diastolic',
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          _field(controller: _notes, label: 'Notes (optional)'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: _textMuted)),
        ),
        TextButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: _primaryBlack),
                )
              : const Text('Save',
                  style: TextStyle(
                      color: _primaryBlack, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

class _MoodLogDialog extends StatefulWidget {
  const _MoodLogDialog();
  @override
  State<_MoodLogDialog> createState() => _MoodLogDialogState();
}

class _MoodLogDialogState extends State<_MoodLogDialog> {
  String _selected = '';
  final _notes = TextEditingController();
  static const _moods = [
    '😄 Great',
    '🙂 Good',
    '😐 Okay',
    '😔 Low',
    '😢 Bad'
  ];

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _creamCard,
      title: const Text('How are you feeling?',
          style: TextStyle(color: _textMain, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: _moods.map((m) {
              final emoji = m.split(' ').first;
              final selected = _selected == m;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => setState(() => _selected = m),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selected ? _primaryBlack : _tanButton,
                        foregroundColor: selected ? _creamBg : _textMain,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.all(4),
                      ),
                      child: Text(emoji,
                          style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_selected.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Selected: $_selected',
                style: const TextStyle(color: _textMuted, fontSize: 14)),
          ],
          const SizedBox(height: 12),
          _field(controller: _notes, label: 'Notes (optional)'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: _textMuted)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: _primaryBlack),
          onPressed: _selected.isEmpty
              ? null
              : () {
                  context.read<HealthDataProvider>().addLog(
                        logType: 'MOOD',
                        value: _selected,
                        unit: '',
                        notes: _notes.text.trim().isEmpty
                            ? null
                            : _notes.text.trim(),
                      );
                  Navigator.pop(context);
                },
          child: const Text('Save', style: TextStyle(color: _creamBg)),
        ),
      ],
    );
  }
}

class _AddMedicationDialog extends StatefulWidget {
  const _AddMedicationDialog();
  @override
  State<_AddMedicationDialog> createState() => _AddMedicationDialogState();
}

class _AddMedicationDialogState extends State<_AddMedicationDialog> {
  final _name = TextEditingController();
  final _dosage = TextEditingController();
  final _time = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _dosage.dispose();
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        backgroundColor: _creamCard,
        title: const Text('Add Medication',
            style: TextStyle(color: _textMain, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _field(controller: _name, label: 'Medication Name'),
            const SizedBox(height: 12),
            _field(controller: _dosage, label: 'Dosage (e.g. 1 tablet)'),
            const SizedBox(height: 12),
            _field(controller: _time, label: 'Time (e.g. 8:00 AM)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: _textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _primaryBlack),
            onPressed: () {
              if (_name.text.trim().isEmpty) return;
              context.read<HealthDataProvider>().addLog(
                    logType: 'MEDICATION',
                    value: _name.text.trim(),
                    unit: 'dose',
                    notes: '${_dosage.text.trim()} • ${_time.text.trim()}',
                  );
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: _creamBg)),
          ),
        ],
      );
}

class _HeartRateDialog extends StatefulWidget {
  const _HeartRateDialog();
  @override
  State<_HeartRateDialog> createState() => _HeartRateDialogState();
}

class _HeartRateDialogState extends State<_HeartRateDialog> {
  final _bpm = TextEditingController();
  final _notes = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _bpm.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final bpm = int.tryParse(_bpm.text);
    if (bpm == null || bpm < 40 || bpm > 220) return;
    final provider = context.read<HealthDataProvider>();
    final notes = _notes.text.trim().isEmpty ? null : _notes.text.trim();
    setState(() => _saving = true);
    final ok = await provider.logHr(bpm, notes: notes);
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: ok ? _vitalSuccess : Colors.red,
      content: Text(ok ? 'Saved to Google Sheet.' : 'Save failed.'),
    ));
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        backgroundColor: _creamCard,
        title: const Text('Log Heart Rate',
            style: TextStyle(color: _textMain, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _field(
              controller: _bpm,
              label: 'BPM (40-220)',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
            ),
            const SizedBox(height: 12),
            _field(controller: _notes, label: 'Notes (optional)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: _textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _primaryBlack),
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: _creamBg),
                  )
                : const Text('Save', style: TextStyle(color: _creamBg)),
          ),
        ],
      );
}

class _AppointmentDialog extends StatefulWidget {
  const _AppointmentDialog();
  @override
  State<_AppointmentDialog> createState() => _AppointmentDialogState();
}

class _AppointmentDialogState extends State<_AppointmentDialog> {
  final _doctor = TextEditingController();
  final _date = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    _doctor.dispose();
    _date.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        backgroundColor: _creamCard,
        title: const Text('Add Appointment',
            style: TextStyle(color: _textMain, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _field(controller: _doctor, label: 'Doctor Name'),
            const SizedBox(height: 12),
            _field(controller: _date, label: 'Date (e.g. Mar 25, 2026)'),
            const SizedBox(height: 12),
            _field(controller: _notes, label: 'Notes (optional)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: _textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _primaryBlack),
            onPressed: () {
              if (_doctor.text.trim().isEmpty) return;
              context.read<HealthDataProvider>().addLog(
                    logType: 'APPOINTMENT',
                    value: _doctor.text.trim(),
                    unit: 'visit',
                    notes:
                        '${_date.text.trim()} • ${_notes.text.trim()}',
                  );
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: _creamBg)),
          ),
        ],
      );
}

class _MonthlySummaryDialog extends StatelessWidget {
  final List<LogEntry> logs;
  const _MonthlySummaryDialog({required this.logs});

  @override
  Widget build(BuildContext context) {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final monthLogs = logs.where((l) => l.timestamp.isAfter(cutoff)).toList();

    final weightLogs = monthLogs.where((l) => l.logType == 'WEIGHT').toList();
    final bpLogs =
        monthLogs.where((l) => l.logType == 'BLOOD_PRESSURE').toList();
    final moodLogs = monthLogs.where((l) => l.logType == 'MOOD').toList();

    final weightVals =
        weightLogs.map((l) => double.tryParse(l.value)).whereType<double>().toList();
    final avgWeight = weightVals.isEmpty
        ? '--'
        : (weightVals.reduce((a, b) => a + b) / weightVals.length)
            .toStringAsFixed(1);
    final minWeight = weightVals.isEmpty
        ? '--'
        : weightVals.reduce((a, b) => a < b ? a : b).toStringAsFixed(1);
    final maxWeight = weightVals.isEmpty
        ? '--'
        : weightVals.reduce((a, b) => a > b ? a : b).toStringAsFixed(1);

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
    final avgBp = bpPairs.isEmpty
        ? '--'
        : '${(bpPairs.map((p) => p[0]).reduce((a, b) => a + b) / bpPairs.length).round()}'
            '/'
            '${(bpPairs.map((p) => p[1]).reduce((a, b) => a + b) / bpPairs.length).round()}';

    final moodGroups = <String, int>{};
    for (final l in moodLogs) {
      moodGroups[l.value] = (moodGroups[l.value] ?? 0) + 1;
    }

    return AlertDialog(
      backgroundColor: _creamCard,
      title: const Text('Monthly Health Summary',
          style: TextStyle(color: _textMain, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _summaryRow('Weight Entries', '${weightLogs.length}'),
            _summaryRow('Avg Weight', '$avgWeight kg'),
            _summaryRow('Weight Range', '$minWeight – $maxWeight kg'),
            const Divider(color: _tanButton),
            _summaryRow('BP Entries', '${bpLogs.length}'),
            _summaryRow('Avg BP', '$avgBp mmHg'),
            const Divider(color: _tanButton),
            _summaryRow('Mood Entries', '${moodLogs.length}'),
            ...moodGroups.entries.map(
              (e) => _summaryRow('  ${e.key}', '${e.value}x'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close', style: TextStyle(color: _primaryBlack)),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
Widget _summaryRow(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: _textMuted, fontSize: 14)),
          Text(value,
              style: const TextStyle(
                  color: _textMain,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
        ],
      ),
    );

Widget _field({
  required TextEditingController controller,
  required String label,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
}) =>
    TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _textMuted),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _tanButton),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _primaryBlack),
        ),
      ),
      style: const TextStyle(color: _textMain),
    );

Widget _dialogButton(
  String label, {
  required VoidCallback onTap,
  Color fill = _tanButton,
  Color fg = _textMain,
  bool bold = false,
}) =>
    SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: fill,
          foregroundColor: fg,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label,
            style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      ),
    );

LogEntry? _latest(List<LogEntry> logs, String type) {
  final filtered = logs.where((l) => l.logType == type);
  if (filtered.isEmpty) return null;
  return filtered.reduce((a, b) => a.timestamp.isAfter(b.timestamp) ? a : b);
}

String _formatDate(DateTime d) {
  const weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  return '${weekdays[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
}
