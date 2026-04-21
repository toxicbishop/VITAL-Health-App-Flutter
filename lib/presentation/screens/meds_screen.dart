import 'package:flutter/material.dart';
import '../../core/app_globals.dart';
import 'package:provider/provider.dart';
import '../../data/models.dart';
import '../providers/health_data_provider.dart';

Color get _creamBg => AppGlobals.creamBg;
Color get _creamCard => AppGlobals.creamCard;
Color get _tanButton => AppGlobals.tanButton;
Color get _textMain => AppGlobals.textMain;
Color get _textMuted => AppGlobals.textMuted;
Color get _primaryBlack => AppGlobals.primaryBlack;
Color get _vitalSuccess => AppGlobals.vitalSuccess;
class MedsScreen extends StatelessWidget {
  const MedsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = context.watch<HealthDataProvider>().logs;
    final meds = logs.where((l) => l.logType == 'MEDICATION').toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final activeCount = meds.length;

    return Container(
      color: _creamBg,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Medications',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _textMain,
              ),
            ),
            Text(
              'Track your daily prescriptions',
              style: TextStyle(color: _textMuted, fontSize: 14),
            ),
            SizedBox(height: 24),
            _ProgressCard(activeCount: activeCount),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Schedule',
                  style: TextStyle(
                    color: _textMain,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$activeCount ${activeCount == 1 ? "Med" : "Meds"}',
                  style: TextStyle(color: _textMuted, fontSize: 12),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (meds.isEmpty)
              const _EmptyState()
            else
              Column(
                children: [
                  for (var i = 0; i < meds.length; i++) ...[
                    _MedicationCard(
                      entry: meds[i],
                      onDelete: () =>
                          context.read<HealthDataProvider>().removeLog(meds[i]),
                    ),
                    if (i != meds.length - 1) SizedBox(height: 12),
                  ],
                ],
              ),
            SizedBox(height: 24),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const _AddMedDialog(),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryBlack,
                  foregroundColor: _creamBg,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  '+ Add New Medication',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final int activeCount;
  const _ProgressCard({required this.activeCount});

  @override
  Widget build(BuildContext context) {
    final hasMeds = activeCount > 0;
    return Container(
      decoration: BoxDecoration(
        color: _creamCard,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "TODAY'S PROGRESS",
                style: TextStyle(
                  color: _textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Text(
                hasMeds ? '$activeCount active' : 'None set',
                style: TextStyle(
                  color: _primaryBlack,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: hasMeds ? 1.0 : 0.0,
              minHeight: 8,
              backgroundColor: _tanButton,
              color: _primaryBlack,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: _creamCard,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Column(
          children: [
            Icon(Icons.medication_outlined, color: _textMuted, size: 40),
            SizedBox(height: 12),
            Text(
              'No medications yet',
              style: TextStyle(
                color: _textMain,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Tap "+ Add New Medication" to start',
              style: TextStyle(color: _textMuted, fontSize: 13),
            ),
          ],
        ),
      );
}

class _MedicationCard extends StatelessWidget {
  final LogEntry entry;
  final VoidCallback onDelete;
  const _MedicationCard({required this.entry, required this.onDelete});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: _creamCard,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _tanButton,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text('💊', style: TextStyle(fontSize: 22)),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.value,
                    style: TextStyle(
                      color: _textMain,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    entry.notes?.isNotEmpty == true
                        ? entry.notes!
                        : '1 dose',
                    style: TextStyle(color: _textMuted, fontSize: 14),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _confirmDelete(context),
              icon: Icon(Icons.delete_outline,
                  color: Color(0xFFB00020), size: 20),
              tooltip: 'Delete',
            ),
          ],
        ),
      );

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _creamCard,
        title: Text('Remove medication?',
            style: TextStyle(color: _textMain, fontWeight: FontWeight.bold)),
        content: Text(
          'Delete "${entry.value}" from your medication list?',
          style: TextStyle(color: _textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: _textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB00020)),
            onPressed: () {
              onDelete();
              Navigator.pop(ctx);
            },
            child: Text('Delete', style: TextStyle(color: _creamBg)),
          ),
        ],
      ),
    );
  }
}

class _AddMedDialog extends StatefulWidget {
  const _AddMedDialog();
  @override
  State<_AddMedDialog> createState() => _AddMedDialogState();
}

class _AddMedDialogState extends State<_AddMedDialog> {
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
        title: Text('Add Medication',
            style: TextStyle(color: _textMain, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _field(controller: _name, label: 'Medication Name'),
            SizedBox(height: 12),
            _field(controller: _dosage, label: 'Dosage (e.g. 1 tablet)'),
            SizedBox(height: 12),
            _field(controller: _time, label: 'Time (e.g. 8:00 AM)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: _textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _primaryBlack),
            onPressed: () {
              final name = _name.text.trim();
              if (name.isEmpty) return;
              final dosage = _dosage.text.trim();
              final time = _time.text.trim();
              final notes = [dosage, time]
                  .where((s) => s.isNotEmpty)
                  .join(' • ');
              context.read<HealthDataProvider>().addLog(
                    logType: 'MEDICATION',
                    value: name,
                    unit: 'dose',
                    notes: notes.isEmpty ? null : notes,
                  );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: _vitalSuccess,
                content: Text('Medication added.'),
              ));
            },
            child: Text('Save', style: TextStyle(color: _creamBg)),
          ),
        ],
      );
}

Widget _field({
  required TextEditingController controller,
  required String label,
}) =>
    TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: _textMuted),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _tanButton),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _primaryBlack),
        ),
      ),
      style: TextStyle(color: _textMain),
    );
