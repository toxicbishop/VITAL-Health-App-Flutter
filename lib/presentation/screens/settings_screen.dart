import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_config_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Color _creamBg(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A1714) : const Color(0xFFF5F3EC);
  Color _creamCard(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2A2520) : const Color(0xFFFAF8F2);
  Color _tanButton(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF3D352C) : const Color(0xFFDBD5C4);
  Color _textMain(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFFE8E0D4) : const Color(0xFF0D0C0A);
  Color _textMuted(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF9C9080) : const Color(0xFF6B6659);
  Color _primaryBlack(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFFE8E0D4) : const Color(0xFF000000);
  Color _dangerRed(BuildContext context) => const Color(0xFFB00020);

  @override
  Widget build(BuildContext context) {
    final cfg = context.watch<AppConfigProvider>();

    return Container(
      color: _creamBg(context),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _textMain(context),
              ),
            ),
            Text(
              'App configuration & preferences',
              style: TextStyle(color: _textMuted(context), fontSize: 14),
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: 'PROFILE', color: _textMuted(context)),
            const SizedBox(height: 8),
            _Card(
              color: _creamCard(context),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.person_outline,
                    label: "Mom's Name",
                    value: cfg.userName.isNotEmpty ? cfg.userName : '--',
                    iconBg: _tanButton(context),
                    iconColor: _primaryBlack(context),
                    labelColor: _textMain(context),
                    valueColor: _textMuted(context),
                    onTap: () => _editName(context, cfg),
                  ),
                  Divider(color: _creamBg(context), height: 1),
                  _InfoRow(
                    icon: Icons.link,
                    label: 'Backend URL',
                    value: cfg.scriptUrl.isNotEmpty
                        ? '${cfg.scriptUrl.substring(0, cfg.scriptUrl.length.clamp(0, 40))}…'
                        : '--',
                    iconBg: _tanButton(context),
                    iconColor: _primaryBlack(context),
                    labelColor: _textMain(context),
                    valueColor: _textMuted(context),
                    onTap: () => _editUrl(context, cfg),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: 'APPEARANCE', color: _textMuted(context)),
            const SizedBox(height: 8),
            _Card(
              color: _creamCard(context),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _primaryBlack(context),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.palette_outlined,
                          color: _creamBg(context), size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text('Theme Mode',
                          style: TextStyle(
                            color: _textMain(context),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          )),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: _creamBg(context),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _tanButton(context)),
                      ),
                      child: DropdownButton<ThemeMode>(
                        value: cfg.themeMode,
                        onChanged: (m) => cfg.setThemeMode(m!),
                        underline: const SizedBox.shrink(),
                        dropdownColor: _creamCard(context),
                        style: TextStyle(
                            color: _textMain(context), fontSize: 14),
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
            _SectionHeader(title: 'ABOUT', color: _textMuted(context)),
            const SizedBox(height: 8),
            _Card(
              color: _creamCard(context),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.info_outline,
                    label: 'Version',
                    value: '2.5.0',
                    iconBg: _tanButton(context),
                    iconColor: _primaryBlack(context),
                    labelColor: _textMain(context),
                    valueColor: _textMuted(context),
                    onTap: null, // Read-only
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
                  foregroundColor: _dangerRed(context),
                  side: BorderSide(color: _dangerRed(context)),
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

  void _editName(BuildContext context, AppConfigProvider cfg) {
    final controller = TextEditingController(text: cfg.userName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _creamCard(context),
        title: Text('Edit Name',
            style: TextStyle(color: _textMain(context), fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          style: TextStyle(color: _textMain(context)),
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: TextStyle(color: _textMuted(context)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: _textMuted(context))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _primaryBlack(context)),
            onPressed: () {
              Navigator.pop(ctx);
              if (controller.text.trim().isNotEmpty) {
                // Update with new name and existing url
                cfg.setConfig(cfg.scriptUrl, controller.text.trim());
              }
            },
            child: Text('Save', style: TextStyle(color: _creamBg(context))),
          ),
        ],
      ),
    );
  }

  void _editUrl(BuildContext context, AppConfigProvider cfg) {
    final controller = TextEditingController(text: cfg.scriptUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _creamCard(context),
        title: Text('Edit Backend URL',
            style: TextStyle(color: _textMain(context), fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          style: TextStyle(color: _textMain(context)),
          decoration: InputDecoration(
            hintText: 'https://script.google.com/...',
            hintStyle: TextStyle(color: _textMuted(context)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: _textMuted(context))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _primaryBlack(context)),
            onPressed: () {
              Navigator.pop(ctx);
              if (controller.text.trim().isNotEmpty) {
                // Update with existing name and new url
                cfg.setConfig(controller.text.trim(), cfg.userName);
              }
            },
            child: Text('Save', style: TextStyle(color: _creamBg(context))),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, AppConfigProvider cfg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _creamCard(context),
        title: Text('Reset Application?',
            style:
                TextStyle(color: _textMain(context), fontWeight: FontWeight.bold)),
        content: Text(
          'This will clear all local data, preferences, and sign you out. '
          'Data saved to Google Sheets is not affected.',
          style: TextStyle(color: _textMuted(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                Text('Cancel', style: TextStyle(color: _textMuted(context))),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: _dangerRed(context)),
            onPressed: () {
              Navigator.pop(ctx);
              cfg.reset();
            },
            child:
                Text('Reset', style: TextStyle(color: _creamBg(context))),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      );
}

class _Card extends StatelessWidget {
  final Widget child;
  final Color color;
  const _Card({required this.child, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconBg;
  final Color iconColor;
  final Color labelColor;
  final Color valueColor;
  final VoidCallback? onTap;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconBg,
    required this.iconColor,
    required this.labelColor,
    required this.valueColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                          color: labelColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        )),
                    Text(value,
                        style: TextStyle(
                            color: valueColor, fontSize: 14)),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.edit_outlined, size: 16, color: valueColor),
            ],
          ),
        ),
      );
}
