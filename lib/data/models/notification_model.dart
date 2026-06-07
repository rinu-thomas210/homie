import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    this.isRead = false,
  });

  String get timeAgo {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}
