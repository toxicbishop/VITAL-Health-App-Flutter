import 'dart:io';

void main() {
  var dir = Directory('lib/presentation/screens');
  for (var file in dir.listSync()) {
    if (file is File && file.path.endsWith('.dart') && file.path.contains('_screen')) {
      if (file.path.contains('settings_screen')) continue;

      var content = file.readAsStringSync();

      // Ensure globals is imported
      if (!content.contains('app_globals.dart')) {
        content = content.replaceFirst(
            'import \'package:flutter/material.dart\';', 
            'import \'package:flutter/material.dart\';\nimport \'../../core/app_globals.dart\';');
      }

      // Replace top-level constants with getters
      content = content.replaceAll(RegExp(r'const _creamBg = Color\(0xFFF5F3EC\);\s*'), 'Color get _creamBg => AppGlobals.creamBg;\n');
      content = content.replaceAll(RegExp(r'const _creamCard = Color\(0xFFFAF8F2\);\s*'), 'Color get _creamCard => AppGlobals.creamCard;\n');
      content = content.replaceAll(RegExp(r'const _tanButton = Color\(0xFFDBD5C4\);\s*'), 'Color get _tanButton => AppGlobals.tanButton;\n');
      content = content.replaceAll(RegExp(r'const _textMain = Color\(0xFF0D0C0A\);\s*'), 'Color get _textMain => AppGlobals.textMain;\n');
      content = content.replaceAll(RegExp(r'const _textMuted = Color\(0xFF6B6659\);\s*'), 'Color get _textMuted => AppGlobals.textMuted;\n');
      content = content.replaceAll(RegExp(r'const _primaryBlack = Color\(0xFF000000\);\s*'), 'Color get _primaryBlack => AppGlobals.primaryBlack;\n');
      content = content.replaceAll(RegExp(r'const _dangerRed = Color\(0xFFB00020\);\s*'), 'Color get _dangerRed => AppGlobals.dangerRed;\n');
      content = content.replaceAll(RegExp(r'const _vitalSuccess = Color\(0xFF27734A\);\s*'), 'Color get _vitalSuccess => AppGlobals.vitalSuccess;\n');
      content = content.replaceAll(RegExp(r'const _successGreen = Color\(0xFF27734A\);\s*'), 'Color get _successGreen => AppGlobals.vitalSuccess;\n');

      // Now, safely strip CONST keywords from typical widget instantiations
      final widgetsWithConst = [
        'Text', 'Icon', 'Padding', 'SizedBox', 'Column', 'Row', 'Center', 
        'Container', 'BoxDecoration', 'EdgeInsets', 'TextStyle', 'BorderSide',
        'RoundedRectangleBorder', 'BouncingScrollPhysics', 'NeverScrollableScrollPhysics',
        'Divider', 'Align', 'Expanded', 'Flexible', 'Spacer'
      ];
      
      for (var w in widgetsWithConst) {
        content = content.replaceAll('const $w(', '$w(');
      }
      
      // also replace const EdgeInsets.all -> EdgeInsets.all
      content = content.replaceAll('const EdgeInsets.', 'EdgeInsets.');
      content = content.replaceAll('const BorderRadius.', 'BorderRadius.');
      content = content.replaceAll('const TextTheme(', 'TextTheme(');

      // Fix specific default parameters in dashboard_screen
      if (file.path.contains('dashboard_screen')) {
         content = content.replaceFirst('Color fill = _tanButton,', 'Color? fill,\n');
         content = content.replaceFirst('Color fg = _textMain,', 'Color? fg,\n');
         // We must manually patch where fill and fg are used in _dialogButton body:
         content = content.replaceAll(RegExp(r'backgroundColor:\s*fill,'), 'backgroundColor: fill ?? _tanButton,');
         content = content.replaceAll(RegExp(r'TextStyle\(.*?color:\s*fg,'), 'TextStyle(color: fg ?? _textMain,');
         // Another occurrence of TextStyle in dialogButton
      }

      file.writeAsStringSync(content);
      print('Processed ${file.path}');
    }
  }
}
