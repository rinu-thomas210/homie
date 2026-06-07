import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/message_model.dart';

class MessageProvider with ChangeNotifier {
  final List<Conversation> _conversations = [
    Conversation(
      id: 'c1',
      otherUserId: '1',
      otherUserName: 'Alex Rivera',
      otherUserPhoto: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      otherUserVerified: true,
      isOnline: true,
      compatibility: 0.92,
      messages: [
        Message(
          id: 'm1',
          senderId: '1',
          text: 'Hey! I saw your profile and I think we\'d be great roommates!',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: true,
        ),
        Message(
          id: 'm2',
          senderId: 'me',
          text: 'Hi Alex! I love your listing in Chelsea. When can we visit?',
          timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
          isRead: true,
        ),
        Message(
          id: 'm3',
          senderId: '1',
          text: 'How about this Saturday at 2pm? The place is even better in person 😊',
          timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
          isRead: true,
        ),
        Message(
          id: 'm4',
          senderId: 'me',
          text: 'Saturday works perfectly for me!',
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          isRead: true,
        ),
        Message(
          id: 'm5',
          senderId: '1',
          text: 'Great! I\'ll send you the address. Looking forward to it! 🏠',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          isRead: false,
        ),
      ],
    ),
    Conversation(
      id: 'c2',
      otherUserId: '2',
      otherUserName: 'Jamie Chen',
      otherUserPhoto: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
      otherUserVerified: true,
      isOnline: false,
      compatibility: 0.88,
      messages: [
        Message(
          id: 'm6',
          senderId: '2',
          text: 'Hi! Your compatibility score with me is 88%. I\'d love to connect!',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          isRead: true,
        ),
        Message(
          id: 'm7',
          senderId: 'me',
          text: 'Hey Jamie! Your architecture work is so impressive.',
          timestamp: DateTime.now().subtract(const Duration(hours: 22)),
          isRead: true,
        ),
        Message(
          id: 'm8',
          senderId: '2',
          text: 'Thank you! I\'m looking in Brooklyn too. Maybe we could look together?',
          timestamp: DateTime.now().subtract(const Duration(hours: 20)),
          isRead: false,
        ),
      ],
    ),
    Conversation(
      id: 'c3',
      otherUserId: '5',
      otherUserName: 'Leo Zhang',
      otherUserPhoto: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
      otherUserVerified: true,
      isOnline: true,
      compatibility: 0.81,
      messages: [
        Message(
          id: 'm9',
          senderId: '5',
          text: 'Hey! Saw you\'re also into remote work and cooking. Same vibes! 🍜',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          isRead: true,
        ),
        Message(
          id: 'm10',
          senderId: 'me',
          text: 'Haha yes! What do you usually cook?',
          timestamp: DateTime.now().subtract(const Duration(days: 2, hours: -1)),
          isRead: true,
        ),
        Message(
          id: 'm11',
          senderId: '5',
          text: 'Lots of Asian food! I\'ll cook for us if you find the place 😄',
          timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 20)),
          isRead: true,
        ),
      ],
    ),
  ];

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
              text: 'Hey roommates! Welcome to our group chat! 🏠 Let\'s use this to stay in touch.',
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

