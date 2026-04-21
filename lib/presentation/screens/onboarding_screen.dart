import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../providers/app_config_provider.dart';

/// Login / onboarding flow styled to match the Kotlin reference app:
/// warm cream background, progress dots, large emoji heading, rounded
/// dark primary button. Collects the Apps Script URL (required by the
/// 3-tier architecture in the PRD) and the user's Name, which is
/// persisted to the Google Sheet Profile tab on completion.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _url = TextEditingController();
  final _name = TextEditingController();
  int _step = 0;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _url.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    setState(() => _error = null);
    switch (_step) {
      case 0:
        setState(() => _step = 1);
        return;
      case 1:
        if (!_url.text.contains('script.google.com')) {
          setState(() => _error = 'Please enter a valid Apps Script URL');
          return;
        }
        setState(() => _step = 2);
        return;
      case 2:
        if (_name.text.trim().isEmpty) {
          setState(() => _error = 'Please enter your name');
          return;
        }
        setState(() => _loading = true);
        final ok = await context.read<AppConfigProvider>().setConfig(
              _url.text.trim(),
              _name.text.trim(),
            );
        if (!mounted) return;
        setState(() => _loading = false);
        if (!ok) {
          setState(() => _error = 'Could not save name to Google Sheet. Check URL and network.');
        }
        // On success, main.dart swaps to HomeScreen via isConfigured.
        return;
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() {
        _step--;
        _error = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              _ProgressDots(step: _step, total: 3),
              const Spacer(flex: 1),
              Expanded(
                flex: 6,
                child: SingleChildScrollView(child: _buildStep()),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: const TextStyle(color: AppColors.error, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    foregroundColor: AppColors.cream,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _loading ? null : _next,
                  child: _loading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: AppColors.cream,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _step == 2 ? 'Log In' : 'Continue',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              if (_step > 0)
                TextButton(
                  onPressed: _loading ? null : _back,
                  child: const Text(
                    'Back',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return const _StepWelcome();
      case 1:
        return _StepUrl(controller: _url);
      case 2:
      default:
        return _StepName(controller: _name);
    }
  }
}

class _ProgressDots extends StatelessWidget {
  final int step;
  final int total;
  const _ProgressDots({required this.step, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final active = i <= step;
        final current = i == step;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Container(
            width: current ? 12 : 8,
            height: current ? 12 : 8,
            decoration: BoxDecoration(
              color: active ? AppColors.textPrimary : AppColors.goldLight,
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}

class _StepWelcome extends StatelessWidget {
  const _StepWelcome();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        Text('🏥', style: TextStyle(fontSize: 64)),
        SizedBox(height: 24),
        Text(
          "Welcome to\nVital Health",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        SizedBox(height: 16),
        Text(
          "Track your weight and blood pressure,\nsafely stored in Mom's Google Sheet.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _StepUrl extends StatelessWidget {
  final TextEditingController controller;
  const _StepUrl({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(child: Text('🔗', style: TextStyle(fontSize: 64))),
        const SizedBox(height: 24),
        const Text(
          'Connect your Sheet',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Paste the Apps Script Web App URL',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Apps Script URL',
            hintText: 'https://script.google.com/macros/s/...',
          ),
          keyboardType: TextInputType.url,
          autocorrect: false,
        ),
      ],
    );
  }
}

class _StepName extends StatelessWidget {
  final TextEditingController controller;
  const _StepName({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(child: Text('👤', style: TextStyle(fontSize: 64))),
        const SizedBox(height: 24),
        const Text(
          "What's your name?",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Saved to the Profile tab of your Google Sheet',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Your name'),
          textCapitalization: TextCapitalization.words,
          autofocus: true,
        ),
      ],
    );
  }
}
