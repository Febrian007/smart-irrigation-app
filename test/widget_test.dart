import 'package:flutter_test/flutter_test.dart';
import 'package:smart_irrigation_app/main.dart';

void main() {
  testWidgets('SmartIrrigationApp renders dashboard title', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartIrrigationApp());
    expect(find.text('Smart Irrigation Monitor'), findsOneWidget);
  });
}
