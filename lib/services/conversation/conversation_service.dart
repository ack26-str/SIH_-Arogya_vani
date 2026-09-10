import '../../models/conversation.dart';
import '../../models/conversation_message.dart';
import '../../models/clinical_summary.dart';

abstract class ConversationService {
  Future<Conversation> startConversation(String patientId, {String language = 'en'});
  Future<ConversationMessage> sendMessage(
    String conversationId,
    String text, {
    bool isVoice = false,
    String? attachedRecordId,
    String? audioBase64,
    String language = 'en',
  });
  Future<Conversation?> getConversation(String conversationId);
  Future<List<Conversation>> getConversationHistory(String patientId);
  Future<ClinicalSummary> generateClinicalSummary(String conversationId);
}
