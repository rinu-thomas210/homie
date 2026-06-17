import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  final List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider();


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
