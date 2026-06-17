import 'package:flutter/foundation.dart';

class ReviewModel {
  final String id;
  final String reviewerName;
  final String reviewerPhotoUrl;
  final String targetUserId;
  final String targetUserName;
  final String? targetListingId; // NEW: for room reviews
  final int rating;
  final String text;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.reviewerName,
    required this.reviewerPhotoUrl,
    required this.targetUserId,
    required this.targetUserName,
    this.targetListingId,
    required this.rating,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'reviewerName': reviewerName,
    'reviewerPhotoUrl': reviewerPhotoUrl,
    'targetUserId': targetUserId,
    'targetUserName': targetUserName,
    'targetListingId': targetListingId,
    'rating': rating,
    'text': text,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
    id: json['id'] as String,
    reviewerName: json['reviewerName'] as String,
    reviewerPhotoUrl: json['reviewerPhotoUrl'] as String,
    targetUserId: json['targetUserId'] as String,
    targetUserName: json['targetUserName'] as String,
    targetListingId: json['targetListingId'] as String?,
    rating: json['rating'] as int,
    text: json['text'] as String,
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  );
}
