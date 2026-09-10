import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sih_clinical_intake/shared/widgets/disclaimer_banner.dart';
import 'package:sih_clinical_intake/shared/widgets/status_chip.dart';
import 'package:sih_clinical_intake/shared/widgets/app_button.dart';
import 'package:sih_clinical_intake/shared/widgets/app_card.dart';
import 'package:sih_clinical_intake/models/medical_record.dart';

void main() {
  group('Shared Widgets Unit Tests', () {
    testWidgets('DisclaimerBanner renders non-diagnostic warning properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DisclaimerBanner(isCompact: true),
          ),
        ),
      );

      expect(find.text('Non-diagnostic assistant for clinical intake preparation.'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
    });

    testWidgets('DisclaimerBanner displays full non-diagnostic notice with emergency note', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DisclaimerBanner(
              isCompact: false,
              showEmergencyNote: true,
            ),
          ),
        ),
      );

      expect(find.textContaining('does not provide a medical diagnosis'), findsOneWidget);
      expect(find.textContaining('112 / 108'), findsOneWidget);
      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('StatusChip renders record status and lab status variants', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                StatusChip.fromRecordStatus(RecordStatus.processed),
                StatusChip.fromRecordStatus(RecordStatus.processing),
                StatusChip.forLabStatus('normal'),
                StatusChip.forLabStatus('critical'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Processed'), findsOneWidget);
      expect(find.text('Analyzing'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);
      expect(find.text('Abnormal'), findsOneWidget);
    });

    testWidgets('AppButton handles tap interactions and loading state', (WidgetTester tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Confirm Intake',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Confirm Intake'), findsOneWidget);
      await tester.tap(find.text('Confirm Intake'));
      expect(tapped, isTrue);

      // Loading state test
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Confirm Intake',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AppCard renders child content with interactive callback', (WidgetTester tester) async {
      var cardTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCard(
              onTap: () => cardTapped = true,
              child: const Text('Clinical Record #101'),
            ),
          ),
        ),
      );

      expect(find.text('Clinical Record #101'), findsOneWidget);
      await tester.tap(find.text('Clinical Record #101'));
      expect(cardTapped, isTrue);
    });
  });
}
