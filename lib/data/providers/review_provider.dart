import 'package:flutter/material.dart';

class ReviewModel {
  final String id;
  final String reviewerName;
  final String reviewerPhotoUrl;
  final String targetUserId;
  final String targetUserName;
  final int rating;
  final String text;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.reviewerName,
    required this.reviewerPhotoUrl,
    required this.targetUserId,
    required this.targetUserName,
    required this.rating,
    required this.text,
    required this.createdAt,
  });
}

class ReviewProvider with ChangeNotifier {
  final List<ReviewModel> _reviews = [];

  List<ReviewModel> get allReviews => List.unmodifiable(_reviews);

  // Reviews written BY the current user
  List<ReviewModel> reviewsBy(String authorName) =>
      _reviews.where((r) => r.reviewerName == authorName).toList();

  // Reviews FOR a particular user
  List<ReviewModel> reviewsFor(String targetUserId) =>
      _reviews.where((r) => r.targetUserId == targetUserId).toList();

  void addReview(ReviewModel review) {
    _reviews.insert(0, review);
    notifyListeners();
  }

  void removeReview(String id) {
    _reviews.removeWhere((r) => r.id == id);
    notifyListeners();
  }
}
