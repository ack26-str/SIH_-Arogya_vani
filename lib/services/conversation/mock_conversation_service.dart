import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../models/conversation.dart';
import '../../models/conversation_message.dart';
import '../../models/clinical_summary.dart';
import '../../models/medication.dart';
import '../../models/allergy.dart';
import 'conversation_service.dart';

class MockConversationService implements ConversationService {
  static const _uuid = Uuid();
  final Map<String, Conversation> _conversations = {};
  int _intakeStep = 0;

  // Track patient answers for summary synthesis
  String _chiefComplaint = 'Fever and body aches';
  String _duration = '2 days';
  String _severity = 'Moderate (101°F)';
  final List<String> _symptoms = ['Fever', 'Headache', 'Chills', 'Fatigue'];
  final List<String> _associated = ['Mild dry cough', 'Loss of appetite'];
  final List<String> _history = ['Type 2 Diabetes (diagnosed 2020)'];
  final List<Medication> _medications = [
    const Medication(name: 'Metformin', dose: '500mg', frequency: 'Twice daily'),
    const Medication(name: 'Paracetamol', dose: '650mg', frequency: 'As needed for fever'),
  ];
  final List<Allergy> _allergies = [
    const Allergy(allergen: 'Penicillin', reaction: 'Skin rash'),
  ];

  MockConversationService() {
    _initDemoData();
  }

  void _initDemoData() {
    // Previous completed consultation
    final pastId = 'conv_past_001';
    final pastTime = DateTime.now().subtract(const Duration(days: 12));
    _conversations[pastId] = Conversation(
      id: pastId,
      patientId: 'pat_001',
      startedAt: pastTime,
      updatedAt: pastTime.add(const Duration(minutes: 15)),
      status: ConversationStatus.summarized,
      messages: [
        ConversationMessage(
          id: 'msg_past_1',
          role: MessageRole.ai,
          text: 'Hello Ramesh! What brings you in today?',
          timestamp: pastTime,
        ),
        ConversationMessage(
          id: 'msg_past_2',
          role: MessageRole.patient,
          text: 'Seasonal allergic rhinitis and nasal congestion.',
          timestamp: pastTime.add(const Duration(minutes: 2)),
        ),
        ConversationMessage(
          id: 'msg_past_3',
          role: MessageRole.ai,
          text: 'Clinical summary prepared and shared with Dr. Anita Sharma.',
          timestamp: pastTime.add(const Duration(minutes: 10)),
        ),
      ],
      collectedData: {
        'title': 'Seasonal Allergic Rhinitis',
        'status': 'Summary Shared',
      },
    );
  }

  @override
  Future<Conversation> startConversation(String patientId, {String language = 'en'}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _intakeStep = 0;
    final convId = 'conv_${_uuid.v4().substring(0, 8)}';
    final initialMessage = ConversationMessage(
      id: _uuid.v4(),
      role: MessageRole.ai,
      text: _getLocalizedGreeting(language),
      language: language,
      timestamp: DateTime.now(),
      quickSuggestions: [
        'Fever & chills',
        'Severe headache',
        'Stomach pain',
        'Cough & sore throat',
      ],
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
    final conv = _conversations[conversationId];
    if (conv == null) {
      throw Exception('Conversation not found');
    }

    // 1. Add patient message
    final patientMsg = ConversationMessage(
      id: _uuid.v4(),
      role: MessageRole.patient,
      text: text,
      timestamp: DateTime.now(),
      isVoice: isVoice,
      attachedRecordId: attachedRecordId,
    );

    List<ConversationMessage> updatedMessages = List.from(conv.messages)..add(patientMsg);
    _conversations[conversationId] = conv.copyWith(
      messages: updatedMessages,
      updatedAt: DateTime.now(),
    );

    // Simulate AI clinical reasoning delay
    await Future.delayed(const Duration(milliseconds: 650));

    // Emergency symptom detection
    final lowerText = text.toLowerCase();
    if (lowerText.contains('chest pain') ||
        lowerText.contains('cannot breathe') ||
        lowerText.contains('heart attack') ||
        lowerText.contains('unconscious')) {
      final emergencyMsg = ConversationMessage(
        id: _uuid.v4(),
        role: MessageRole.system,
        text: '⚠️ EMERGENCY ALERT: You reported symptoms that could require immediate care. '
            'Please seek immediate emergency assistance by dialing 112 / 108 or visiting the nearest emergency department.',
        timestamp: DateTime.now(),
        quickSuggestions: ['Call 112 Emergency', 'I am safe, continue intake'],
      );
      updatedMessages = List.from(updatedMessages)..add(emergencyMsg);
      _conversations[conversationId] = conv.copyWith(messages: updatedMessages);
      return emergencyMsg;
    }

    _intakeStep++;
    final aiResponse = _determineNextClinicalQuestion(_intakeStep, text);

    updatedMessages = List.from(updatedMessages)..add(aiResponse);
    _conversations[conversationId] = conv.copyWith(
      messages: updatedMessages,
      updatedAt: DateTime.now(),
      status: _intakeStep >= 5 ? ConversationStatus.completed : ConversationStatus.inProgress,
    );

    return aiResponse;
  }

  ConversationMessage _determineNextClinicalQuestion(int step, String previousText) {
    switch (step) {
      case 1:
        _chiefComplaint = previousText;
        return ConversationMessage(
          id: _uuid.v4(),
          role: MessageRole.ai,
          text: "I'm sorry you're experiencing that. How long have you had these symptoms?",
          timestamp: DateTime.now(),
          quickSuggestions: [
            'For 2 days',
            'Since yesterday',
            'Over a week',
            'Started today',
          ],
        );
      case 2:
        _duration = previousText;
        return ConversationMessage(
          id: _uuid.v4(),
          role: MessageRole.ai,
          text: 'Have you measured your body temperature? How severe is the discomfort?',
          timestamp: DateTime.now(),
          quickSuggestions: [
            'Yes, measured 101.4°F',
            'Mild fever with chills',
            'Severe pain (8/10)',
            'Haven\'t measured yet',
          ],
        );
      case 3:
        _severity = previousText;
        return ConversationMessage(
          id: _uuid.v4(),
          role: MessageRole.ai,
          text: 'Are you having any associated symptoms such as headache, cough, vomiting, or body aches?',
          timestamp: DateTime.now(),
          quickSuggestions: [
            'Severe headache and chills',
            'Mild dry cough',
            'Body pain and fatigue',
            'No other symptoms',
          ],
        );
      case 4:
        return ConversationMessage(
          id: _uuid.v4(),
          role: MessageRole.ai,
          text: 'Do you have any existing health conditions (like diabetes or high blood pressure), or take regular medications?',
          timestamp: DateTime.now(),
          quickSuggestions: [
            'Type 2 Diabetes on Metformin',
            'Hypertension (BP)',
            'Taking Paracetamol 650mg',
            'No existing conditions',
          ],
        );
      case 5:
      default:
        return ConversationMessage(
          id: _uuid.v4(),
          role: MessageRole.ai,
          text: 'Do you have any known allergies to medicines or food?',
          timestamp: DateTime.now(),
          quickSuggestions: [
            'Allergic to Penicillin',
            'Sulfa drug allergy',
            'No known allergies',
          ],
        );
    }
  }

  String _getLocalizedGreeting(String language) {
    switch (language) {
      case 'hi':
        return 'नमस्ते! मैं आपसे आपके स्वास्थ्य के बारे में कुछ सवाल पूछूँगा ताकि हम आपके डॉक्टर के लिए एक संरचित सारांश तैयार कर सकें। आज आपको क्या समस्या है?';
      case 'ml':
        return 'നമസ്കാരം! നിങ്ങളുടെ ഡോക്ടർക്കായി ഒരു ക്ലിനിക്കൽ സംഗ്രഹം തയ്യാറാക്കുന്നതിനായി ഞാൻ ചില ചോദ്യങ്ങൾ ചോദിക്കാം. ഇന്ന് നിങ്ങൾക്ക് എന്ത് അസ്വസ്ഥതയാണ് ഉള്ളത്?';
      case 'ta':
        return 'வணக்கம்! உங்கள் மருத்துவருக்கான சுருக்கத்தை தயாரிக்க சில கேள்விகளைக் கேட்கிறேன். இன்று உங்களுக்கு என்ன பிரச்சனை?';
      case 'te':
        return 'నమస్కారం! మీ వైద్యుని కోసం క్లినికల్ సారాంశాన్ని సిద్ధం చేయడానికి నేను కొన్ని ప్రశ్నలు అడుగుతాను. మీకు ఎలాంటి సమస్య ఉంది?';
      case 'kn':
        return 'ನಮಸ್ಕಾರ! ನಿಮ್ಮ ವೈದ್ಯರಿಗಾಗಿ ಸಾರಾಂಶವನ್ನು ಸಿದ್ಧಪಡಿಸಲು ನಾನು ಕೆಲವು ಪ್ರಶ್ನೆಗಳನ್ನು ಕೇಳುತ್ತೇನೆ. ನಿಮಗೆ ಏನು ತೊಂದರೆಯಾಗಿದೆ?';
      case 'en':
      default:
        return "Hello! I'll ask you a few questions about your health so we can prepare a structured clinical summary for your healthcare provider. What symptoms are you experiencing today?";
    }
  }

  @override
  Future<Conversation?> getConversation(String conversationId) async {
    return _conversations[conversationId];
  }

  @override
  Future<List<Conversation>> getConversationHistory(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _conversations.values.toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  @override
  Future<ClinicalSummary> generateClinicalSummary(String conversationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ClinicalSummary(
      id: 'sum_${_uuid.v4().substring(0, 8)}',
      patientId: 'pat_001',
      patientName: 'Ramesh Kumar',
      patientAge: 48,
      patientGender: 'Male',
      createdAt: DateTime.now(),
      chiefComplaint: _chiefComplaint,
      symptoms: _symptoms,
      onset: 'Sudden onset 48 hours ago',
      duration: _duration,
      severity: _severity,
      associatedSymptoms: _associated,
      medicalHistory: _history,
      currentMedications: _medications,
      allergies: _allergies,
      previousTreatments: const [
        'OTC Paracetamol 650mg taken 6 hours ago with temporary relief',
        'Oral rehydration and bed rest',
      ],
      attachedRecords: const [
        'CBC_Blood_Report_Aug2026.pdf',
        'Rx_Diabetes_Followup.jpg',
      ],
      additionalNotes:
          'Patient reports good hydration, no travel history in past 14 days. Denies shortness of breath.',
      status: SummaryStatus.draft,
    );
  }
}
