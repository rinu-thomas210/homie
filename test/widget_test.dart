import 'package:flutter_test/flutter_test.dart';
import 'package:homie/main.dart';

void main() {
  testWidgets('Homie App Smoke Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HomieApp());

    // Verify that onboarding or splash screen starts up
    expect(find.byType(HomieApp), findsOneWidget);
    
    // Settle any pending animations/timers
    await tester.pumpAndSettle();
  });
}
