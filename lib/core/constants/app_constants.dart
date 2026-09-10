class AppConstants {
  AppConstants._();

  static const String appName = 'AarogyaVani';
  static const String appTagline = 'Your health. Your voice. Better care.';
  static const String appSubtitle = 'Multilingual AI-Powered Clinical Intake & Medical-Record Assistant';

  static const String nonDiagnosticDisclaimer =
      'This assistant helps collect and organize health information. '
      'It does not provide a medical diagnosis. '
      'Please consult a qualified healthcare professional for medical advice.';

  static const String emergencyWarning =
      'If you are experiencing severe symptoms such as sudden chest pain, '
      'loss of consciousness, or severe difficulty breathing, please seek immediate '
      'emergency care or call 112 / 108 immediately.';

  static const String emergencyNumber = '112 / 108';

  static const List<String> supportedFileExtensions = [
    'pdf',
    'jpg',
    'jpeg',
    'png',
  ];

  static const int maxFileSizeMb = 15;

  // Language Definitions
  static const List<LanguageOption> supportedLanguages = [
    LanguageOption(
      code: 'en',
      englishName: 'English',
      nativeName: 'English',
      scriptSnippet: 'Hello, how can we help you?',
    ),
    LanguageOption(
      code: 'hi',
      englishName: 'Hindi',
      nativeName: 'हिन्दी',
      scriptSnippet: 'नमस्ते, हम आपकी क्या मदद कर सकते हैं?',
    ),
    LanguageOption(
      code: 'ml',
      englishName: 'Malayalam',
      nativeName: 'മലയാളം',
      scriptSnippet: 'നമസ്കാരം, ഞങ്ങൾക്ക് നിങ്ങളെ എങ്ങനെ സഹായിക്കാനാകും?',
    ),
    LanguageOption(
      code: 'ta',
      englishName: 'Tamil',
      nativeName: 'தமிழ்',
      scriptSnippet: 'வணக்கம், நாங்கள் உங்களுக்கு எவ்வாறு உதவலாம்?',
    ),
    LanguageOption(
      code: 'te',
      englishName: 'Telugu',
      nativeName: 'తెలుగు',
      scriptSnippet: 'నమస్కారం, మేము మీకు ఎలా సహాయపడగలం?',
    ),
    LanguageOption(
      code: 'kn',
      englishName: 'Kannada',
      nativeName: 'ಕನ್ನಡ',
      scriptSnippet: 'ನಮಸ್ಕಾರ, ನಾವು ನಿಮಗೆ ಹೇಗೆ ಸಹಾಯ ಮಾಡಬಹುದು?',
    ),
  ];
}

class LanguageOption {
  final String code;
  final String englishName;
  final String nativeName;
  final String scriptSnippet;

  const LanguageOption({
    required this.code,
    required this.englishName,
    required this.nativeName,
    required this.scriptSnippet,
  });
}
