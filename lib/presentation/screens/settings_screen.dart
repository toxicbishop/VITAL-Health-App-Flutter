import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_config_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cfg = context.watch<AppConfigProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Mom\'s Name'),
            subtitle: Text(cfg.userName),
          ),
          ListTile(
            title: const Text('Backend URL'),
            subtitle: Text(cfg.scriptUrl),
          ),
          const Divider(),
          ListTile(
            title: const Text('Theme Mode'),
            trailing: DropdownButton<ThemeMode>(
              value: cfg.themeMode,
              onChanged: (m) => cfg.setThemeMode(m!),
              items: const [
                DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
              ],
            ),
          ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: () {
              cfg.reset();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset Application'),
          ),
        ],
      ),
    );
  }
}
