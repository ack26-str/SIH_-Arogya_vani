import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';
import '../../models/conversation.dart';
import '../../models/conversation_message.dart';
import '../../models/clinical_summary.dart';
import '../../models/medication.dart';
import '../../models/allergy.dart';
import '../../core/network/api_client.dart';
import 'conversation_service.dart';

class RealConversationService implements ConversationService {
  final Dio _dio = ApiClient().dio;
  static const _uuid = Uuid();
  
  final Map<String, Conversation> _conversations = {};
  
  @override
  Future<Conversation> startConversation(String patientId, {String language = 'en'}) async {
    try {
      // Need a session ID in our new backend design. 
      // This is a bit of a hack since the UI doesn't track sessions directly yet, 
      // but we can create one on the fly for the patient.
      final sessResponse = await _dio.post('/sessions/create', data: {
        'patient_id': patientId,
        'department_config': 'ALLOPATHIC_OPD',
        'language': language,
      });
      final sessionId = sessResponse.data['id'];

      final response = await _dio.post('/conversations/start', data: {
        'patient_id': patientId,
        'session_id': sessionId,
        'department_config': 'ALLOPATHIC_OPD',
        'language': language,
      });
      
      final convId = response.data['conversation_id'];
      final initialMessageText = response.data['message'];
      
      final initialMessage = ConversationMessage(
        id: _uuid.v4(),
        role: MessageRole.ai,
        text: initialMessageText,
        language: language,
        timestamp: DateTime.now(),
      );

      final conv = Conversation(
        id: convId,
        patientId: patientId,
        startedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        messages: [initialMessage],
        status: ConversationStatus.inProgress,
      );

      _conversations[convId] = conv;
      return conv;
    } catch (e) {
      print('Error starting conversation: $e');
      throw Exception('Failed to start conversation');
    }
  }

  @override
  Future<ConversationMessage> sendMessage(
    String conversationId,
    String text, {
    bool isVoice = false,
    String? attachedRecordId,
    String? audioBase64,
    String language = 'en',
  }) async {
    // NOTE: We do NOT guard on _conversations[conversationId] here.
    // The local map is volatile (cleared on app restart), but the backend
    // is the source of truth. We send the request directly.
    final conv = _conversations[conversationId]; // May be null after restart — that's fine.

    // Don't send placeholder UI text as clinical data
    final cleanText = (text == '\ud83d\udd0a Voice message' || text.trim().isEmpty) ? '' : text.trim();

    // Track messages list for local cache update (may stay null if conv not in memory)
    List<ConversationMessage>? updatedMessages;

    if (conv != null) {
      final patientMsg = ConversationMessage(
        id: _uuid.v4(),
        role: MessageRole.patient,
        text: cleanText.isEmpty ? '🔊 Voice message' : cleanText,
        timestamp: DateTime.now(),
        isVoice: isVoice,
        attachedRecordId: attachedRecordId,
      );
      updatedMessages = List<ConversationMessage>.from(conv.messages)..add(patientMsg);
      _conversations[conversationId] = conv.copyWith(
        messages: updatedMessages,
        updatedAt: DateTime.now(),
      );
    }

    try {
      final response = await _dio.post('/conversations/$conversationId/message', data: {
        'text': cleanText.isEmpty ? null : cleanText,
        'audio_base64': audioBase64,
        'fallback_text': cleanText.isNotEmpty ? cleanText : null,
        'language': language,
        'is_voice': isVoice,
      });
      
      final replyText = response.data['reply_text'];
      final audioUrl = response.data['audio_url'];
      final currentPhase = response.data['current_phase'];
      final isComplete = response.data['is_complete'] ?? false;
      
      final completenessScore = (response.data['completeness_score'] as num?)?.toDouble() ?? 0.0;

      // Build metadata tags so controller can observe backend state without a schema change
      final List<String> metadataTags = [
        '__SCORE__${completenessScore.toStringAsFixed(2)}',
        '__PHASE__$currentPhase',
        if (isComplete) '__COMPLETE__',
      ];

      final aiResponse = ConversationMessage(
        id: _uuid.v4(),
        role: MessageRole.ai,
        text: replyText ?? '',
        timestamp: DateTime.now(),
        audioUrl: audioUrl,
        quickSuggestions: metadataTags,
      );

      // Update local cache if we have it
      if (conv != null) {
        final withAi = List<ConversationMessage>.from(updatedMessages ?? conv.messages)..add(aiResponse);
        _conversations[conversationId] = conv.copyWith(
          messages: withAi,
          updatedAt: DateTime.now(),
          status: isComplete ? ConversationStatus.completed : ConversationStatus.inProgress,
        );
      }

      return aiResponse;
    } catch (e) {
      print('Error sending message: $e');
      final errorMsg = ConversationMessage(
        id: _uuid.v4(),
        role: MessageRole.system,
        text: 'Connection error. Please try sending your message again.',
        timestamp: DateTime.now(),
      );
      return errorMsg;
    }
  }

  @override
  Future<Conversation?> getConversation(String conversationId) async {
    return _conversations[conversationId];
  }

  @override
  Future<List<Conversation>> getConversationHistory(String patientId) async {
    return _conversations.values.toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  @override
  Future<ClinicalSummary> generateClinicalSummary(String conversationId) async {
    try {
      final response = await _dio.get('/conversations/$conversationId/summary');
      final data = response.data;
      
      // If the backend returns a wrapper {"status": "draft", "summary": {...}}
      final summaryData = (data is Map && data.containsKey('summary')) ? data['summary'] : data;
      
      final currentConv = _conversations[conversationId];
      final patientId = currentConv?.patientId ?? 'unknown';

      List<String> parseStringList(dynamic raw) {
        if (raw == null) return [];
        if (raw is List) {
          return raw.map((e) {
            if (e is Map) {
              return (e['name'] ?? e['condition'] ?? e['label'] ?? e.values.firstOrNull ?? '').toString();
            }
            return e.toString();
          }).where((s) => s.isNotEmpty).toList();
        }
        return [];
      }

      List<Medication> parseMedications(dynamic raw) {
        if (raw == null) return [];
        if (raw is List) {
          return raw.map((e) {
            if (e is Map) {
              return Medication(
                name: (e['name'] ?? 'Unknown Medication').toString(),
                dose: e['dose']?.toString() ?? e['dosage']?.toString(),
                frequency: e['frequency']?.toString(),
              );
            }
            return Medication(name: e.toString());
          }).toList();
        }
        return [];
      }

      List<Allergy> parseAllergies(dynamic raw) {
        if (raw == null) return [];
        if (raw is List) {
          return raw.map((e) {
            if (e is Map) {
              return Allergy(
                allergen: (e['allergen'] ?? e['name'] ?? 'Unknown').toString(),
                reaction: e['reaction']?.toString(),
              );
            }
            return Allergy(allergen: e.toString());
          }).toList();
        }
        return [];
      }

      // Extract symptoms
      List<String> symptoms = parseStringList(summaryData['symptoms']);
      if (symptoms.isEmpty) {
        symptoms = parseStringList(summaryData['associations']);
      }
      if (symptoms.isEmpty && summaryData['chief_complaint'] != null) {
        symptoms = [summaryData['chief_complaint'].toString()];
      }

      final associated = parseStringList(summaryData['associations']);
      final medicalHistory = parseStringList(summaryData['past_medical_history'] ?? summaryData['medical_history']);
      final surgicalHistory = parseStringList(summaryData['past_surgical_history']);
      final fullHistory = [
        ...medicalHistory,
        ...surgicalHistory.map((s) => 'Surgical: $s'),
      ];

      final onset = summaryData['onset']?.toString() ?? 'Not reported';
      final duration = summaryData['timing']?.toString() ?? summaryData['duration']?.toString() ?? 'Not reported';
      final severity = summaryData['severity']?.toString() ?? 'Moderate';

      return ClinicalSummary(
        id: 'sum_${_uuid.v4().substring(0, 8)}',
        patientId: patientId,
        patientName: summaryData['patient']?['name']?.toString() ?? 'Patient $patientId',
        patientAge: int.tryParse(summaryData['patient']?['age']?.toString() ?? '0') ?? 0,
        patientGender: summaryData['patient']?['gender']?.toString() ?? 'Unknown',
        createdAt: DateTime.now(),
        chiefComplaint: summaryData['chief_complaint']?.toString() ?? 'Not specified',
        symptoms: symptoms,
        onset: onset,
        duration: duration,
        severity: severity,
        associatedSymptoms: associated,
        medicalHistory: fullHistory,
        currentMedications: parseMedications(summaryData['drug_history'] ?? summaryData['medications']),
        allergies: parseAllergies(summaryData['allergy_history'] ?? summaryData['allergies']),
        previousTreatments: parseStringList(summaryData['previous_treatments']),
        attachedRecords: const [],
        additionalNotes: summaryData['vitals']?.toString() ?? (summaryData['character'] != null ? 'Character: ${summaryData['character']}' : ''),
        status: (data is Map && data['status'] == 'draft') ? SummaryStatus.draft : SummaryStatus.confirmed,
      );
    } catch (e) {
      print('Error generating summary: $e');
      throw Exception('Failed to generate clinical summary: $e');
    }
  }
}
