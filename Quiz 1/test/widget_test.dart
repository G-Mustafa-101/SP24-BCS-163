import 'package:flutter_test/flutter_test.dart';
import 'package:quiz1/main.dart';

void main() {
  testWidgets('Dice App loads correctly', (WidgetTester tester) async {

    await tester.pumpWidget(const DiceApp());

    // Check if title appears
    expect(find.text('Simple Dice App'), findsOneWidget);

    // Check if Roll Dice button exists
    expect(find.text('Roll Dice'), findsOneWidget);
  });
}