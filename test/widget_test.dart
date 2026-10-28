import 'package:flutter_test/flutter_test.dart';

import 'package:visitor_management/main.dart';

void main() {
  testWidgets('VisitorApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VisitorApp());
    // Advance past the 250ms mock network latency
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.text('Front Desk Console'), findsOneWidget);
    expect(find.text('Total Visitors Today'), findsOneWidget);
  });
}
