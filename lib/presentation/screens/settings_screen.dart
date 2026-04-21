import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_config_provider.dart';

const _creamBg = Color(0xFFF5F3EC);
const _creamCard = Color(0xFFFAF8F2);
const _tanButton = Color(0xFFDBD5C4);
const _textMain = Color(0xFF0D0C0A);
const _textMuted = Color(0xFF6B6659);
const _primaryBlack = Color(0xFF000000);
const _dangerRed = Color(0xFFB00020);

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cfg = context.watch<AppConfigProvider>();

    return Container(
      color: _creamBg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _textMain,
              ),
            ),
            const Text(
              'App configuration & preferences',
              style: TextStyle(color: _textMuted, fontSize: 14),
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: 'PROFILE'),
            const SizedBox(height: 8),
            _Card(
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.person_outline,
                    label: "Mom's Name",
                    value: cfg.userName.isNotEmpty ? cfg.userName : '--',
                  ),
                  const Divider(color: _creamBg, height: 1),
                  _InfoRow(
                    icon: Icons.link,
                    label: 'Backend URL',
                    value: cfg.scriptUrl.isNotEmpty
                        ? '${cfg.scriptUrl.substring(0, cfg.scriptUrl.length.clamp(0, 40))}…'
                        : '--',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: 'APPEARANCE'),
            const SizedBox(height: 8),
            _Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _primaryBlack,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.palette_outlined,
                          color: _creamBg, size: 20),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text('Theme Mode',
                          style: TextStyle(
                            color: _textMain,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          )),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: _creamBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _tanButton),
                      ),
                      child: DropdownButton<ThemeMode>(
                        value: cfg.themeMode,
                        onChanged: (m) => cfg.setThemeMode(m!),
                        underline: const SizedBox.shrink(),
                        dropdownColor: _creamCard,
                        style: const TextStyle(
                            color: _textMain, fontSize: 14),
                        items: const [
                          DropdownMenuItem(
                              value: ThemeMode.system,
                              child: Text('System')),
                          DropdownMenuItem(
                              value: ThemeMode.light,
                              child: Text('Light')),
                          DropdownMenuItem(
                              value: ThemeMode.dark,
                              child: Text('Dark')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: 'ABOUT'),
            const SizedBox(height: 8),
            _Card(
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.info_outline,
                    label: 'Version',
                    value: '1.0.0',
                  ),
                  const Divider(color: _creamBg, height: 1),
                  _InfoRow(
                    icon: Icons.flutter_dash_outlined,
                    label: 'Framework',
                    value: 'Flutter + GAS',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 54,
              child: OutlinedButton(
                onPressed: () => _confirmReset(context, cfg),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _dangerRed,
                  side: const BorderSide(color: _dangerRed),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Reset Application',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context, AppConfigProvider cfg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _creamCard,
        title: const Text('Reset Application?',
            style:
                TextStyle(color: _textMain, fontWeight: FontWeight.bold)),
        content: const Text(
          'This will clear all local data, preferences, and sign you out. '
          'Data saved to Google Sheets is not affected.',
          style: TextStyle(color: _textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Cancel', style: TextStyle(color: _textMuted)),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: _dangerRed),
            onPressed: () {
              Navigator.pop(ctx);
              cfg.reset();
            },
            child:
                const Text('Reset', style: TextStyle(color: _creamBg)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: const TextStyle(
          color: _textMuted,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      );
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: _creamCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _tanButton,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: _primaryBlack, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                        color: _textMain,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      )),
                  Text(value,
                      style: const TextStyle(
                          color: _textMuted, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      );
}
