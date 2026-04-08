import 'package:flutter_test/flutter_test.dart';
import 'package:f1show_mobile/main.dart';

void main() {
  testWidgets('F1Show app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const F1ShowApp());
    expect(find.byType(F1ShowApp), findsOneWidget);
  });
}
