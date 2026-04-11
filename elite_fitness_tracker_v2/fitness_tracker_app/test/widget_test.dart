import 'package:flutter_test/flutter_test.dart';
import 'package:elite_fitness_tracker/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EliteFitnessApp());
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.text('ELITE FITNESS'), findsOneWidget);
  });
}
