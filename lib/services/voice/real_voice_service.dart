import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'voice_service.dart';

class RealVoiceService implements VoiceService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speechToText = stt.SpeechToText();

  bool _isListening = false;
  bool _isSttInitialized = false;
  String? _tempAudioPath;
  String _latestRecognizedText = '';

  RealVoiceService() {
    _initTts();
  }

  // Speech rate for elderly users: 0.5 = half speed, clear and unhurried.
  static const double _ttsRate = 0.5;
  static const double _ttsPitch = 1.0;
  static const double _ttsVolume = 1.0;

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage("en-IN");
      await _flutterTts.setSpeechRate(_ttsRate);
      await _flutterTts.setPitch(_ttsPitch);
      await _flutterTts.setVolume(_ttsVolume);
    } catch (e) {
      print('[VoiceService] TTS init error: $e');
    }
  }

  Future<bool> _ensureSttInitialized() async {
    if (_isSttInitialized) return _speechToText.isAvailable;
    try {
      _isSttInitialized = await _speechToText.initialize(
        onError: (err) => print('[VoiceService] STT Error: ${err.errorMsg}'),
        onStatus: (status) {
          print('[VoiceService] STT Status: $status');
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
          }
        },
        debugLogging: false,
      );
      return _isSttInitialized;
    } catch (e) {
      print('[VoiceService] Failed to init STT: $e');
      _isSttInitialized = false;
      return false;
    }
  }

  @override
  bool get isListening => _isListening;

  @override
  bool get isSpeechAvailable => _isSttInitialized && _speechToText.isAvailable;

  @override
  String get lastRecognizedWords => _latestRecognizedText;

  @override
  Future<bool> startListening({
    void Function(String recognizedWords, bool isFinal)? onResult,
    String language = 'en',
  }) async {
    try {
      _latestRecognizedText = '';
      
      final hasStt = await _ensureSttInitialized();
      if (hasStt && await _speechToText.hasPermission) {
        final locale = _sttLocale(language);
        await _speechToText.listen(
          onResult: (result) {
            _latestRecognizedText = result.recognizedWords;
            onResult?.call(result.recognizedWords, result.finalResult);
          },
          listenOptions: stt.SpeechListenOptions(
            listenMode: stt.ListenMode.dictation,
            partialResults: true,
            pauseFor: const Duration(seconds: 4),
            listenFor: const Duration(seconds: 45),
            localeId: locale,
          ),
        );
        _isListening = true;
        return true;
      }

      // Fallback: If STT service is unavailable, record audio via record package
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        _tempAudioPath = '${dir.path}/recording.wav';
        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.wav),
          path: _tempAudioPath!,
        );
        _isListening = true;
        return true;
      }
    } catch (e) {
      print('[VoiceService] Error starting listening: $e');
    }
    _isListening = false;
    return false;
  }

  @override
  Future<String?> stopListening() async {
    if (!_isListening) return null;
    _isListening = false;

    try {
      if (_speechToText.isListening) {
        await _speechToText.stop();
      }

      String? base64String;
      if (await _audioRecorder.isRecording()) {
        final path = await _audioRecorder.stop();
        if (path != null) {
          final file = File(path);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            base64String = base64Encode(bytes);
          }
        }
      }

      return jsonEncode({
        "text": _latestRecognizedText.trim(),
        "fallbackText": _latestRecognizedText.trim(),
        "base64": base64String,
      });
    } catch (e) {
      print('[VoiceService] Error stopping listening: $e');
    }
    return null;
  }

  @override
  Future<void> speak(String text, {String language = 'en', String? audioBase64}) async {
    if (audioBase64 != null && audioBase64.isNotEmpty) {
      // Play Bhashini TTS audio (Base64 WAV)
      try {
        final bytes = base64Decode(audioBase64);
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/response.wav');
        await file.writeAsBytes(bytes);
        await _audioPlayer.play(DeviceFileSource(file.path));
        return; // Bhashini audio played — done
      } catch (e) {
        print('[TTS] Error playing Bhashini audio: $e. Falling back to flutter_tts.');
      }
    }

    // Offline fallback — flutter_tts with correct locale
    final locale = _ttsLocale(language);
    await _flutterTts.setLanguage(locale);
    await _flutterTts.setSpeechRate(_ttsRate);
    await _flutterTts.setVolume(_ttsVolume);
    await _flutterTts.speak(text);
  }

  /// Maps language codes to speech_to_text locale tags.
  String _sttLocale(String code) {
    switch (code) {
      case 'hi': return 'hi_IN';
      case 'ta': return 'ta_IN';
      case 'te': return 'te_IN';
      case 'kn': return 'kn_IN';
      case 'ml': return 'ml_IN';
      case 'en': return 'en_IN';
      default:   return 'en_IN';
    }
  }

  /// Maps language codes to flutter_tts locale strings.
  String _ttsLocale(String code) {
    switch (code) {
      case 'hi': return 'hi-IN';
      case 'ta': return 'ta-IN';
      case 'te': return 'te-IN';
      case 'kn': return 'kn-IN';
      case 'ml': return 'ml-IN';
      case 'bn': return 'bn-IN';
      case 'gu': return 'gu-IN';
      case 'mr': return 'mr-IN';
      case 'pa': return 'pa-IN';
      case 'or': return 'or-IN';
      case 'as': return 'as-IN';
      case 'ur': return 'ur-IN';
      case 'en': return 'en-IN';
      default:   return 'en-IN';
    }
  }
}
