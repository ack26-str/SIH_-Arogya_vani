import 'conversation_message.dart';

enum ConversationStatus { inProgress, completed, summarized }

class Conversation {
  final String id;
  final String patientId;
  final DateTime startedAt;
  final DateTime updatedAt;
  final List<ConversationMessage> messages;
  final ConversationStatus status;
  final Map<String, dynamic> collectedData;

  const Conversation({
    required this.id,
    required this.patientId,
    required this.startedAt,
    required this.updatedAt,
    required this.messages,
    this.status = ConversationStatus.inProgress,
    this.collectedData = const {},
  });

  Conversation copyWith({
    String? id,
    String? patientId,
    DateTime? startedAt,
    DateTime? updatedAt,
    List<ConversationMessage>? messages,
    ConversationStatus? status,
    Map<String, dynamic>? collectedData,
  }) {
    return Conversation(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      startedAt: startedAt ?? this.startedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      status: status ?? this.status,
      collectedData: collectedData ?? this.collectedData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'startedAt': startedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'messages': messages.map((m) => m.toJson()).toList(),
      'status': status.name,
      'collectedData': collectedData,
    };
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      messages: (json['messages'] as List<dynamic>?)
              ?.map((m) => ConversationMessage.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      status: ConversationStatus.values
          .byName(json['status'] as String? ?? 'inProgress'),
      collectedData: json['collectedData'] as Map<String, dynamic>? ?? {},
    );
  }
}
