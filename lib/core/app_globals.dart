import 'package:flutter/material.dart';

class AppGlobals {
  static bool isDark = false;
  static Color get creamBg => isDark ? const Color(0xFF1A1714) : const Color(0xFFF5F3EC);
  static Color get creamCard => isDark ? const Color(0xFF2A2520) : const Color(0xFFFAF8F2);
  static Color get tanButton => isDark ? const Color(0xFF3D352C) : const Color(0xFFDBD5C4);
  static Color get textMain => isDark ? const Color(0xFFE8E0D4) : const Color(0xFF0D0C0A);
  static Color get textMuted => isDark ? const Color(0xFF9C9080) : const Color(0xFF6B6659);
  static Color get primaryBlack => isDark ? const Color(0xFFE8E0D4) : const Color(0xFF000000);
  static Color get vitalSuccess => const Color(0xFF27734A);
  static Color get dangerRed => const Color(0xFFB00020);
}
