import 'package:flutter_test/flutter_test.dart';
import 'package:sih_clinical_intake/services/conversation/mock_conversation_service.dart';
import 'package:sih_clinical_intake/models/conversation_message.dart';

void main() {
  group('Services Tests', () {
    // Patient and Document mock services were removed when migrating to Real services.
    // TODO: Add integration tests using RealPatientService and RealDocumentService.

    test('MockConversationService multi-turn intake dialog and summary generation', () async {
      final service = MockConversationService();
      final conv = await service.startConversation('pat_001', language: 'en');
      expect(conv.messages.isNotEmpty, isTrue);
      expect(conv.messages.first.role, MessageRole.ai);

      // Send a user reply
      final reply = await service.sendMessage(
        conv.id,
        'I have a headache and high fever since yesterday',
      );
      expect(reply.role, MessageRole.ai);
      expect(reply.text.isNotEmpty, isTrue);

      // Verify conversation tracking
      final fetchedConv = await service.getConversation(conv.id);
      expect(fetchedConv, isNotNull);
      expect(fetchedConv!.messages.length, greaterThanOrEqualTo(3));

      // Generate doctor-ready clinical summary
      final summary = await service.generateClinicalSummary(conv.id);
      expect(summary.patientId, 'pat_001');
      expect(summary.chiefComplaint.isNotEmpty, isTrue);
      expect(summary.symptoms.isNotEmpty, isTrue);
      expect(summary.currentMedications.isNotEmpty, isTrue);
    });
  });
}
