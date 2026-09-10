import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sih_clinical_intake/main.dart';

void main() {
  testWidgets('AarogyaVaniApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: AarogyaVaniApp(),
      ),
    );

    // Initial pump for splash screen
    await tester.pump();
    expect(find.byType(AarogyaVaniApp), findsOneWidget);

    // Advance past splash timer to welcome screen
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pump();
    expect(find.byType(AarogyaVaniApp), findsOneWidget);
  });
}
