import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:snakezilla/main.dart';

void main() {
  testWidgets('App renders title', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: SnakezillaApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('SNAKEZILLA'), findsOneWidget);
  });
}
