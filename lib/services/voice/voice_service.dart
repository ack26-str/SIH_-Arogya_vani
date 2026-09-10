abstract class VoiceService {
  /// Starts listening for speech with optional real-time text callback.
  Future<bool> startListening({
    void Function(String recognizedWords, bool isFinal)? onResult,
    String language = 'en',
  });

  /// Stops listening and returns recognized text (or audio data), or null on failure.
  Future<String?> stopListening();

  /// Plays the audioBase64 (if provided) or uses local TTS to speak the text.
  Future<void> speak(String text, {String language = 'en', String? audioBase64});

  bool get isListening;

  /// Whether speech-to-text recognition service is available on this device.
  bool get isSpeechAvailable;

  /// The most recent recognized speech text.
  String get lastRecognizedWords;
}
