import 'package:uuid/uuid.dart';


class Message {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;

  Message({
    String? id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
  }) : id = id ?? const Uuid().v4();
}

class Conversation {
  final String id;
  final String otherUserId;
  final String otherUserName;
  final String otherUserPhoto;
  final bool otherUserVerified;
  final List<Message> messages;
  final bool isOnline;
  final double compatibility;
  final bool isGroup;
  final List<String> memberIds;

  Conversation({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserPhoto,
    required this.otherUserVerified,
    required this.messages,
    this.isOnline = false,
    this.compatibility = 0.0,
    this.isGroup = false,
    this.memberIds = const [],
  });

  Message? get lastMessage => messages.isEmpty ? null : messages.last;
  int get unreadCount => messages.where((m) => !m.isRead && m.senderId != 'me').length;
}
