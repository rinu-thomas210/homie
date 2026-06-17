import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/message_model.dart';

class MessageProvider with ChangeNotifier {
  final List<Conversation> _conversations = [];

  List<Conversation> get conversations => List.unmodifiable(_conversations);

  Conversation? getConversation(String id) {
    try {
      return _conversations.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  void sendMessage(String conversationId, String text) {
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx != -1) {
      final conv = _conversations[idx];
      final newMsg = Message(
        senderId: 'me',
        text: text,
        timestamp: DateTime.now(),
        isRead: true,
      );
      _conversations[idx] = Conversation(
        id: conv.id,
        otherUserId: conv.otherUserId,
        otherUserName: conv.otherUserName,
        otherUserPhoto: conv.otherUserPhoto,
        otherUserVerified: conv.otherUserVerified,
        messages: [...conv.messages, newMsg],
        isOnline: conv.isOnline,
        compatibility: conv.compatibility,
        isGroup: conv.isGroup,
        memberIds: conv.memberIds,
      );
      notifyListeners();
    }
  }

  int get totalUnread =>
      _conversations.fold(0, (sum, c) => sum + c.unreadCount);

  void startConversation(String userId, String userName, String userPhoto,
      bool userVerified, double compatibility) {
    final exists = _conversations.any((c) => c.otherUserId == userId);
    if (!exists) {
      _conversations.insert(
        0,
        Conversation(
          id: const Uuid().v4(),
          otherUserId: userId,
          otherUserName: userName,
          otherUserPhoto: userPhoto,
          otherUserVerified: userVerified,
          messages: [],
          isOnline: false,
          compatibility: compatibility,
        ),
      );
      notifyListeners();
    }
  }

  void startRoommateGroup(List<String> roommateIds) {
    final exists = _conversations.any((c) => c.id == 'group_roommates');
    if (!exists) {
      _conversations.insert(
        0,
        Conversation(
          id: 'group_roommates',
          otherUserId: 'group',
          otherUserName: 'Roommate Group',
          otherUserPhoto: 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=400',
          otherUserVerified: true,
          messages: [
            Message(
              id: 'gm1',
              senderId: roommateIds.isNotEmpty ? roommateIds.first : '1',
              text: 'Hey roommates! Welcome to our group chat! Let\'s use this to stay in touch.',
              timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
              isRead: true,
            ),
            Message(
              id: 'gm2',
              senderId: roommateIds.length > 1 ? roommateIds[1] : '3',
              text: 'Awesome! So excited to split expenses and rent together.',
              timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
              isRead: true,
            ),
          ],
          isOnline: true,
          compatibility: 0.95,
          isGroup: true,
          memberIds: ['me', ...roommateIds],
        ),
      );
      notifyListeners();
    }
  }
}

