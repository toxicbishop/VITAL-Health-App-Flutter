import 'package:flutter/material.dart';

class AppGlobals {
  static bool isDark = false;
  static Color get creamBg =>
      isDark ? const Color(0xFF1A1714) : const Color(0xFFF5F3EC);
  static Color get creamCard =>
      isDark ? const Color(0xFF2A2520) : const Color(0xFFFAF8F2);
  static Color get creamCardTop =>
      isDark ? const Color(0xFF352E27) : const Color(0xFFFFFCF5);
  static Color get tanButton =>
      isDark ? const Color(0xFF3D352C) : const Color(0xFFDBD5C4);
  static Color get tanButtonLifted =>
      isDark ? const Color(0xFF51483E) : const Color(0xFFECE5D0);
  static Color get textMain =>
      isDark ? const Color(0xFFE8E0D4) : const Color(0xFF0D0C0A);
  static Color get textMuted =>
      isDark ? const Color(0xFF9C9080) : const Color(0xFF6B6659);
  static Color get primaryBlack =>
      isDark ? const Color(0xFFE8E0D4) : const Color(0xFF000000);
  static Color get vitalSuccess => const Color(0xFF27734A);
  static Color get dangerRed => const Color(0xFFB00020);
  static Color get surfaceBorder =>
      isDark ? const Color(0xFF463D33) : const Color(0xFFE8E0CF);
  static Color get glowGold =>
      isDark ? const Color(0x66C9A96E) : const Color(0x55D6BE83);
  static Color get softRose =>
      isDark ? const Color(0xFF4A272D) : const Color(0xFFFFECE8);
  static Color get softSage =>
      isDark ? const Color(0xFF203A2D) : const Color(0xFFEAF4EA);
  static Color get softSky =>
      isDark ? const Color(0xFF203241) : const Color(0xFFE8F1F8);

  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: isDark ? const Color(0xAA000000) : const Color(0x1A6B5B3E),
      blurRadius: 24,
      offset: const Offset(0, 14),
    ),
    BoxShadow(
      color: isDark ? const Color(0x223D352C) : const Color(0x90FFFFFF),
      blurRadius: 1,
      offset: const Offset(0, -1),
    ),
  ];
}

class AppRevealAnimation extends StatelessWidget {
  final Widget child;
  final Duration delay;
  const AppRevealAnimation({super.key, required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 520 + delay.inMilliseconds),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final delayed =
            ((value * (520 + delay.inMilliseconds)) - delay.inMilliseconds)
                .clamp(0.0, 520.0) /
            520.0;
        return Opacity(
          opacity: delayed,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - delayed)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
