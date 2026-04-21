import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_globals.dart';
import '../providers/app_config_provider.dart';

Color get _creamBg => AppGlobals.isDark ? const Color(0xFF1A1714) : const Color(0xFFF5F3EC);
Color get _textMain => AppGlobals.textMain;
Color get _textMuted => AppGlobals.textMuted;
Color get _primaryBlack => AppGlobals.primaryBlack;
Color get _tanButton => AppGlobals.tanButton;

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
        return;
    }
  }

  void _back() => setState(() { if (_step > 0) _step--; _error = null; });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _creamBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              _ProgressDots(step: _step, total: 3),
              const Spacer(),
              Expanded(flex: 6, child: SingleChildScrollView(child: _buildStep())),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: TextStyle(color: AppGlobals.dangerRed, fontSize: 14), textAlign: TextAlign.center),
              ],
              const SizedBox(height: 16),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBlack,
                    foregroundColor: _creamBg,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _loading ? null : _next,
                  child: _loading
                      ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: _creamBg, strokeWidth: 2))
                      : Text(_step == 2 ? 'Log In' : 'Continue', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              if (_step > 0)
                TextButton(
                  onPressed: _loading ? null : _back,
                  child: Text('Back', style: TextStyle(color: _textMuted)),
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
      case 0: return const _StepWelcome();
      case 1: return _StepUrl(controller: _url);
      default: return _StepName(controller: _name);
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
              color: active ? _primaryBlack : _tanButton,
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
  Widget build(BuildContext context) => Column(children: [
    const Text('🏥', style: TextStyle(fontSize: 64)),
    const SizedBox(height: 24),
    Text("Welcome to\nVital Health", textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _textMain, height: 1.2)),
    const SizedBox(height: 16),
    Text("Track your health signals safely\nsynced to your Google Sheet.", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: _textMuted, height: 1.4)),
  ]);
}

class _StepUrl extends StatelessWidget {
  final TextEditingController controller;
  const _StepUrl({required this.controller});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    const Center(child: Text('🔗', style: TextStyle(fontSize: 64))),
    const SizedBox(height: 24),
    Text('Connect Sheet', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _textMain)),
    const SizedBox(height: 8),
    Text('Paste your Apps Script Web App URL', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: _textMuted)),
    const SizedBox(height: 24),
    _field(controller: controller, label: 'Apps Script URL', hint: 'https://script.google.com/...', type: TextInputType.url),
  ]);
}

class _StepName extends StatelessWidget {
  final TextEditingController controller;
  const _StepName({required this.controller});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    const Center(child: Text('👤', style: TextStyle(fontSize: 64))),
    const SizedBox(height: 24),
    Text("What's your name?", textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _textMain)),
    const SizedBox(height: 8),
    Text('Saved to the Profile tab of your Google Sheet', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: _textMuted)),
    const SizedBox(height: 24),
    _field(controller: controller, label: 'Your name', caps: TextCapitalization.words),
  ]);
}

Widget _field({required TextEditingController controller, required String label, String? hint, TextInputType type = TextInputType.text, TextCapitalization caps = TextCapitalization.none}) => TextField(
  controller: controller,
  textCapitalization: caps,
  keyboardType: type,
  style: TextStyle(color: _textMain),
  decoration: InputDecoration(
    labelText: label,
    hintText: hint,
    labelStyle: TextStyle(color: _textMuted),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _tanButton)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _primaryBlack)),
  ),
);
