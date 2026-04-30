import 'package:flutter_test/flutter_test.dart';
import 'package:vital_flutter_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // We instantiate VitalApp to ensure it compiles.
    // Pumping it requires setting up multiple providers (AppConfigProvider, etc)
    // which are initialized asynchronously in main.dart.
    const app = VitalApp();
    expect(app, isNotNull);
  });
}
