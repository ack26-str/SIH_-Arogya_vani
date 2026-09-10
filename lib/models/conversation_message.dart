enum MessageRole { ai, patient, system }

class ConversationMessage {
  final String id;
  final MessageRole role;
  final String text;
  final String language;
  final DateTime timestamp;
  final List<String> quickSuggestions;
  final String? attachedRecordId;
  final bool isVoice;
  final String? audioUrl;

  const ConversationMessage({
    required this.id,
    required this.role,
    required this.text,
    this.language = 'en',
    required this.timestamp,
    this.quickSuggestions = const [],
    this.attachedRecordId,
    this.isVoice = false,
    this.audioUrl,
  });

  ConversationMessage copyWith({
    String? id,
    MessageRole? role,
    String? text,
    String? language,
    DateTime? timestamp,
    List<String>? quickSuggestions,
    String? attachedRecordId,
    bool? isVoice,
    String? audioUrl,
  }) {
    return ConversationMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      text: text ?? this.text,
      language: language ?? this.language,
      timestamp: timestamp ?? this.timestamp,
      quickSuggestions: quickSuggestions ?? this.quickSuggestions,
      attachedRecordId: attachedRecordId ?? this.attachedRecordId,
      isVoice: isVoice ?? this.isVoice,
      audioUrl: audioUrl ?? this.audioUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.name,
      'text': text,
      'language': language,
      'timestamp': timestamp.toIso8601String(),
      'quickSuggestions': quickSuggestions,
      'attachedRecordId': attachedRecordId,
      'isVoice': isVoice,
      'audioUrl': audioUrl,
    };
  }

  factory ConversationMessage.fromJson(Map<String, dynamic> json) {
    return ConversationMessage(
      id: json['id'] as String,
      role: MessageRole.values.byName(json['role'] as String? ?? 'ai'),
      text: json['text'] as String,
      language: json['language'] as String? ?? 'en',
      timestamp: DateTime.parse(json['timestamp'] as String),
      quickSuggestions: (json['quickSuggestions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      attachedRecordId: json['attachedRecordId'] as String?,
      isVoice: json['isVoice'] as bool? ?? false,
      audioUrl: json['audioUrl'] as String?,
    );
  }
}
