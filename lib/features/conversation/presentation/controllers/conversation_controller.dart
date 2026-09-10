import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../models/conversation.dart';
import '../../../../models/conversation_message.dart';
import '../../../../models/clinical_summary.dart';
import 'dart:convert';
import '../../../../services/service_providers.dart';

class ConversationState {
  final Conversation? conversation;
  final bool isLoading;
  final bool isAiTyping;
  final bool isListening;
  final String liveTranscribedText;
  final bool isComplete;
  final double completenessScore;
  final String currentPhase;
  final String? error;
  final List<String> currentSuggestions;

  const ConversationState({
    this.conversation,
    this.isLoading = false,
    this.isAiTyping = false,
    this.isListening = false,
    this.liveTranscribedText = '',
    this.isComplete = false,
    this.completenessScore = 0.0,
    this.currentPhase = 'CHIEF_COMPLAINT',
    this.error,
    this.currentSuggestions = const [],
  });

  ConversationState copyWith({
    Conversation? conversation,
    bool? isLoading,
    bool? isAiTyping,
    bool? isListening,
    String? liveTranscribedText,
    bool? isComplete,
    double? completenessScore,
    String? currentPhase,
    String? error,
    List<String>? currentSuggestions,
  }) {
    return ConversationState(
      conversation: conversation ?? this.conversation,
      isLoading: isLoading ?? this.isLoading,
      isAiTyping: isAiTyping ?? this.isAiTyping,
      isListening: isListening ?? this.isListening,
      liveTranscribedText: liveTranscribedText ?? this.liveTranscribedText,
      isComplete: isComplete ?? this.isComplete,
      completenessScore: completenessScore ?? this.completenessScore,
      currentPhase: currentPhase ?? this.currentPhase,
      error: error,
      currentSuggestions: currentSuggestions ?? this.currentSuggestions,
    );
  }
}

class ConversationNotifier extends StateNotifier<ConversationState> {
  final Ref _ref;

  ConversationNotifier(this._ref) : super(const ConversationState());

  void clearError() {
    state = state.copyWith(error: null);
  }

  void updateLiveTranscription(String text) {
    state = state.copyWith(liveTranscribedText: text);
  }

  Future<void> initConversation() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final service = _ref.read(conversationServiceProvider);
      final lang = _ref.read(selectedLanguageCodeProvider);
      final patient = _ref.read(currentPatientProvider).value;
      final patientId = patient?.id ?? 'pat_demo';

      final conv = await service.startConversation(patientId, language: lang);
      final initialSuggestions = conv.messages.isNotEmpty
          ? conv.messages.last.quickSuggestions
          : <String>[];

      state = state.copyWith(
        conversation: conv,
        isLoading: false,
        isComplete: false,
        completenessScore: 0.0,
        currentPhase: 'CHIEF_COMPLAINT',
        currentSuggestions: initialSuggestions,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> sendMessage({String text = '', String? audioBase64, String? attachedRecordId}) async {
    final currentConv = state.conversation;
    final messageText = text.trim();
    if (currentConv == null || messageText.isEmpty) return;

    final isVoice = (audioBase64 != null && audioBase64.isNotEmpty) || state.liveTranscribedText.isNotEmpty;
    final lang = _ref.read(selectedLanguageCodeProvider);

    final tempMsg = ConversationMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.patient,
      text: messageText,
      timestamp: DateTime.now(),
      isVoice: isVoice,
      attachedRecordId: attachedRecordId,
    );

    final updatedMessages = List<ConversationMessage>.from(currentConv.messages)..add(tempMsg);
    state = state.copyWith(
      conversation: currentConv.copyWith(messages: updatedMessages),
      isAiTyping: true,
      currentSuggestions: [],
    );

    try {
      final service = _ref.read(conversationServiceProvider);
      final aiResponse = await service.sendMessage(
        currentConv.id,
        messageText,
        isVoice: isVoice,
        audioBase64: audioBase64,
        attachedRecordId: attachedRecordId,
        language: lang,
      );

      final fullMessages = List<ConversationMessage>.from(updatedMessages)..add(aiResponse);

      // Read backend-driven state from metadata tags in quickSuggestions
      final isComplete = aiResponse.quickSuggestions.contains('__COMPLETE__');
      final scoreTag = aiResponse.quickSuggestions
          .firstWhere((s) => s.startsWith('__SCORE__'), orElse: () => '');
      final phaseTag = aiResponse.quickSuggestions
          .firstWhere((s) => s.startsWith('__PHASE__'), orElse: () => '');
      final score = scoreTag.isNotEmpty
          ? double.tryParse(scoreTag.replaceFirst('__SCORE__', '')) ?? state.completenessScore
          : state.completenessScore;
      final phase = phaseTag.isNotEmpty
          ? phaseTag.replaceFirst('__PHASE__', '')
          : state.currentPhase;

      final displaySuggestions = aiResponse.quickSuggestions
          .where((s) => !s.startsWith('__'))
          .toList();

      state = state.copyWith(
        conversation: currentConv.copyWith(
          messages: fullMessages,
          status: isComplete ? ConversationStatus.completed : ConversationStatus.inProgress,
        ),
        isAiTyping: false,
        isComplete: isComplete,
        completenessScore: score,
        currentPhase: phase,
        currentSuggestions: displaySuggestions,
      );

      if (aiResponse.text.isNotEmpty || (aiResponse.audioUrl != null && aiResponse.audioUrl!.isNotEmpty)) {
        final voiceService = _ref.read(voiceServiceProvider);
        await voiceService.speak(aiResponse.text, audioBase64: aiResponse.audioUrl);
      }
    } catch (e) {
      state = state.copyWith(
        isAiTyping: false,
        error: 'Failed to send message. Please retry.',
      );
    }
  }

  Future<void> toggleVoiceInput({
    void Function(String liveText)? onLiveText,
    String? fallbackText,
  }) async {
    final voiceService = _ref.read(voiceServiceProvider);
    final lang = _ref.read(selectedLanguageCodeProvider);

    if (state.isListening) {
      final resultJson = await voiceService.stopListening();
      state = state.copyWith(isListening: false);

      String recognizedText = state.liveTranscribedText.trim();
      if (recognizedText.isEmpty && fallbackText != null && fallbackText.trim().isNotEmpty) {
        recognizedText = fallbackText.trim();
      }
      String? audioBase64;

      if (resultJson != null) {
        try {
          final data = jsonDecode(resultJson);
          final parsedText = (data['text'] ?? data['fallbackText'] ?? '').toString().trim();
          if (parsedText.isNotEmpty) {
            recognizedText = parsedText;
          }
          audioBase64 = data['base64'];
        } catch (_) {
          if (resultJson.trim().isNotEmpty) {
            recognizedText = resultJson.trim();
          }
        }
      }

      state = state.copyWith(liveTranscribedText: '');

      if (recognizedText.isNotEmpty) {
        onLiveText?.call(recognizedText);
        await sendMessage(
          text: recognizedText,
          audioBase64: audioBase64,
        );
      } else {
        state = state.copyWith(
          error: 'No speech recognized. Please speak clearly into the mic or type your symptoms.',
        );
      }
    } else {
      state = state.copyWith(isListening: true, liveTranscribedText: '');
      final started = await voiceService.startListening(
        language: lang,
        onResult: (words, isFinal) {
          state = state.copyWith(liveTranscribedText: words);
          onLiveText?.call(words);
        },
      );
      if (!started) {
        state = state.copyWith(
          isListening: false,
          error: 'Microphone or speech recognition unavailable. Please type or grant permission.',
        );
      }
    }
  }

  Future<ClinicalSummary> generateSummary() async {
    final currentConv = state.conversation;
    if (currentConv == null) throw Exception('No active conversation');
    final service = _ref.read(conversationServiceProvider);
    return await service.generateClinicalSummary(currentConv.id);
  }
}

final conversationNotifierProvider =
    StateNotifierProvider<ConversationNotifier, ConversationState>((ref) {
  return ConversationNotifier(ref);
});

final pastConsultationsProvider = FutureProvider<List<Conversation>>((ref) async {
  final service = ref.watch(conversationServiceProvider);
  final patient = ref.watch(currentPatientProvider).value;
  return await service.getConversationHistory(patient?.id ?? 'pat_001');
});
