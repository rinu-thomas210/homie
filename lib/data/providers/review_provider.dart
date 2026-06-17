import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../services/local_db_service.dart';

class ReviewProvider with ChangeNotifier {
  final List<ReviewModel> _reviews = [];
  final LocalDbService _db = LocalDbService();
  bool _initialized = false;

  List<ReviewModel> get allReviews => List.unmodifiable(_reviews);

  /// Load reviews from local storage
  Future<void> loadReviews() async {
    if (_initialized) return;
    await _db.init();
    final jsonList = _db.getReviews();
    _reviews.clear();
    for (final json in jsonList) {
      _reviews.add(ReviewModel.fromJson(json));
    }
    _initialized = true;
    notifyListeners();
  }

  // Reviews written BY the current user
  List<ReviewModel> reviewsBy(String authorName) =>
      _reviews.where((r) => r.reviewerName == authorName).toList();

  // Reviews FOR a particular user
  List<ReviewModel> reviewsFor(String targetUserId) =>
      _reviews.where((r) => r.targetUserId == targetUserId).toList();

  // Reviews FOR a particular listing/room
  List<ReviewModel> reviewsForListing(String listingId) =>
      _reviews.where((r) => r.targetListingId == listingId).toList();

  // Average rating for a listing
  double averageRatingForListing(String listingId) {
    final listingReviews = reviewsForListing(listingId);
    if (listingReviews.isEmpty) return 0.0;
    final total = listingReviews.fold<int>(0, (sum, r) => sum + r.rating);
    return total / listingReviews.length;
  }

  void addReview(ReviewModel review) {
    _reviews.insert(0, review);
    _persist();
    notifyListeners();
  }

  void removeReview(String id) {
    _reviews.removeWhere((r) => r.id == id);
    _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    await _db.init();
    await _db.saveReviews(_reviews.map((r) => r.toJson()).toList());
  }
}
