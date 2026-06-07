import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  final List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider() {
    _seedNotifications();
  }

  void _seedNotifications() {
    final now = DateTime.now();
    _notifications.addAll([
      NotificationModel(
        id: '1',
        icon: Icons.bolt_rounded,
        color: AppColors.primary,
        title: 'New Match Found!',
        subtitle: 'Alex Rivera is a 92% match with you. Check out their profile!',
        timestamp: now.subtract(const Duration(minutes: 2)),
        isRead: false,
      ),
      NotificationModel(
        id: '2',
        icon: Icons.chat_bubble_rounded,
        color: AppColors.accentGreen,
        title: 'New Message',
        subtitle: 'Sarah Kim sent you a message: "Hey! Your profile looks great..."',
        timestamp: now.subtract(const Duration(minutes: 15)),
        isRead: false,
      ),
      NotificationModel(
        id: '3',
        icon: Icons.bookmark_rounded,
        color: AppColors.primary,
        title: 'Profile Saved',
        subtitle: 'Jordan Taylor saved your profile. They might be interested!',
        timestamp: now.subtract(const Duration(hours: 1)),
        isRead: true,
      ),
      NotificationModel(
        id: '4',
        icon: Icons.home_rounded,
        color: AppColors.accentOrange,
        title: 'New Listing Nearby',
        subtitle: 'A new room is available in Manhattan for \$1,200/mo – matches your budget!',
        timestamp: now.subtract(const Duration(hours: 3)),
        isRead: true,
      ),
      NotificationModel(
        id: '5',
        icon: Icons.star_rounded,
        color: AppColors.accentOrange,
        title: 'You got a review!',
        subtitle: 'Maria S. left a 5-star review on your profile.',
        timestamp: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
      NotificationModel(
        id: '6',
        icon: Icons.verified_rounded,
        color: AppColors.verified,
        title: 'Profile Verified',
        subtitle: 'Your email has been verified. Your profile now shows a verified badge.',
        timestamp: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),
      NotificationModel(
        id: '7',
        icon: Icons.bolt_rounded,
        color: AppColors.primary,
        title: '3 New Matches',
        subtitle: 'You have 3 new roommate matches above 80% compatibility this week.',
        timestamp: now.subtract(const Duration(days: 3)),
        isRead: true,
      ),
    ]);
  }

  void addNotification({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    final notif = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      icon: icon,
      color: color,
      title: title,
      subtitle: subtitle,
      timestamp: DateTime.now(),
      isRead: false,
    );
    _notifications.insert(0, notif);
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (final n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void removeNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }
}
