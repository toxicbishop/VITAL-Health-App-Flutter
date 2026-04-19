import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_data_provider.dart';
import '../providers/app_config_provider.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final name = context.select<AppConfigProvider, String>((p) => p.userName);
    final busy = context.select<HealthDataProvider, bool>((p) => p.isBusy);

    return Scaffold(
      appBar: AppBar(
        title: Text('VITAL: $name'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Center(
        child: busy
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _MenuButton(
                      label: 'Log Weight Only',
                      icon: Icons.monitor_weight_outlined,
                      color: Colors.blue,
                      onTap: () => _showLogWeight(context),
                    ),
                    const SizedBox(height: 20),
                    _MenuButton(
                      label: 'Log BP Only',
                      icon: Icons.favorite_outline,
                      color: Colors.red,
                      onTap: () => _showLogBP(context),
                    ),
                    const SizedBox(height: 20),
                    _MenuButton(
                      label: 'Log Both',
                      icon: Icons.add_chart_outlined,
                      color: Colors.purple,
                      onTap: () => _showLogBoth(context),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _showLogWeight(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Weight (kg)'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. 72.5'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final val = double.tryParse(controller.text);
              if (val != null) {
                Navigator.pop(ctx);
                final success = await context.read<HealthDataProvider>().logWeight(val);
                if (context.mounted) _showResult(context, success);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLogBP(BuildContext context) {
    final sys = TextEditingController();
    final dia = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log BP'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: sys,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Systolic'),
            ),
            TextField(
              controller: dia,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Diastolic'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final s = int.tryParse(sys.text);
              final d = int.tryParse(dia.text);
              if (s != null && d != null) {
                Navigator.pop(ctx);
                final success = await context.read<HealthDataProvider>().logBP(s, d);
                if (context.mounted) _showResult(context, success);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLogBoth(BuildContext context) {
    final w = TextEditingController();
    final sys = TextEditingController();
    final dia = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Weight & BP'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: w,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
              ),
              TextField(
                controller: sys,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Systolic'),
              ),
              TextField(
                controller: dia,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Diastolic'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final wv = double.tryParse(w.text);
              final s = int.tryParse(sys.text);
              final d = int.tryParse(dia.text);
              if (wv != null && s != null && d != null) {
                Navigator.pop(ctx);
                final success = await context.read<HealthDataProvider>().logBoth(wv, s, d);
                if (context.mounted) _showResult(context, success);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showResult(BuildContext context, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Log saved successfully!' : 'Failed to save log.'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
          borderRadius: BorderRadius.circular(16),
          color: color.withValues(alpha: 0.05),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
