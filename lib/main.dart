import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'presentation/providers/app_config_provider.dart';
import 'presentation/providers/health_data_provider.dart';
import 'presentation/providers/journal_provider.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'core/app_globals.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfigProvider();
  await config.load();
  
  final journal = JournalProvider(() => config.client);
  await journal.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: config),
        ChangeNotifierProvider.value(value: journal),
        ChangeNotifierProvider(
          create: (_) => HealthDataProvider(() => config.client),
        ),
      ],
      child: const VitalApp(),
    ),
  );
}

class VitalApp extends StatelessWidget {
  const VitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppConfigProvider>(
      builder: (context, cfg, _) {
          return MaterialApp(
            title: 'VITAL (PRD)',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: cfg.themeMode,
            builder: (ctx, child) {
              AppGlobals.isDark = Theme.of(ctx).brightness == Brightness.dark;
              return child!;
            },
            home: cfg.isConfigured ? const DashboardScreen() : const OnboardingScreen(),
          );
        },
      );
    }
  }
