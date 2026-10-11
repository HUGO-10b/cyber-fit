import 'package:flutter_test/flutter_test.dart';
import 'package:cyberfit_mobile/main.dart';

void main() {
  testWidgets('CyberFit smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CyberFitApp());
    expect(find.byType(CyberFitApp), findsOneWidget);
  });
}
