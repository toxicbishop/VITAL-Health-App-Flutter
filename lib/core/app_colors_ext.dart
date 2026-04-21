import 'package:flutter/material.dart';

extension ContextColorsExt on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get creamBg => isDark ? const Color(0xFF1A1714) : const Color(0xFFF5F3EC);
  Color get creamCard => isDark ? const Color(0xFF2A2520) : const Color(0xFFFAF8F2);
  Color get tanButton => isDark ? const Color(0xFF3D352C) : const Color(0xFFDBD5C4);
  Color get textMain => isDark ? const Color(0xFFE8E0D4) : const Color(0xFF0D0C0A);
  Color get textMuted => isDark ? const Color(0xFF9C9080) : const Color(0xFF6B6659);
  Color get primaryBlack => isDark ? const Color(0xFFE8E0D4) : const Color(0xFF000000);
  Color get dangerRed => const Color(0xFFB00020);
  Color get successGreen => const Color(0xFF27734A);
}
