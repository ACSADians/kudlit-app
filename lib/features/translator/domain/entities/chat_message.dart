import 'package:meta/meta.dart';

/// A single message in the Butty chat history.
@immutable
class ChatMessage {
  const ChatMessage({
    this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  /// Local SQLite primary key. Null when not yet persisted.
  final int? id;

  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage copyWith({
    int? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
