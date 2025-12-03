import 'package:flutter_test/flutter_test.dart';
import 'package:sinterklaas_mini_games/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SinterklaasApp());

    // Verify that the home screen loads
    expect(find.text('Sinterklaas Surprise!'), findsOneWidget);
  });
}
