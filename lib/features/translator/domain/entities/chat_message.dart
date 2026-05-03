import 'dart:typed_data';
import 'package:meta/meta.dart';

/// A single message in the Butty chat history.
@immutable
class ChatMessage {
  const ChatMessage({
    this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.imageBytes,
  });

  /// Local SQLite primary key. Null when not yet persisted.
  final int? id;

  final String text;
  final bool isUser;
  final DateTime timestamp;
  
  /// Optional raw image bytes for multimodal queries.
  final Uint8List? imageBytes;

  ChatMessage copyWith({
    int? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    Uint8List? imageBytes,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      imageBytes: imageBytes ?? this.imageBytes,
    );
  }
}
