import 'package:flutter/material.dart';

class SavedListingsProvider with ChangeNotifier {
  // Saved property listing IDs
  final Set<String> _savedListingIds = {};

  // Liked / wishlisted roommate user IDs
  final Set<String> _likedUserIds = {};

  // ── Listings ──────────────────────────────────────────────────────────────

  Set<String> get savedListingIds => _savedListingIds;

  bool isSaved(String listingId) => _savedListingIds.contains(listingId);

  void toggleSave(String listingId) {
    if (_savedListingIds.contains(listingId)) {
      _savedListingIds.remove(listingId);
    } else {
      _savedListingIds.add(listingId);
    }
    notifyListeners();
  }

  void saveListings(String listingId) {
    _savedListingIds.add(listingId);
    notifyListeners();
  }

  void removeSavedListing(String listingId) {
    _savedListingIds.remove(listingId);
    notifyListeners();
  }

  // ── Liked Roommates ───────────────────────────────────────────────────────

  Set<String> get likedUserIds => _likedUserIds;

  bool isLiked(String userId) => _likedUserIds.contains(userId);

  void toggleLike(String userId) {
    if (_likedUserIds.contains(userId)) {
      _likedUserIds.remove(userId);
    } else {
      _likedUserIds.add(userId);
    }
    notifyListeners();
  }

  void likeUser(String userId) {
    _likedUserIds.add(userId);
    notifyListeners();
  }

  void unlikeUser(String userId) {
    _likedUserIds.remove(userId);
    notifyListeners();
  }

  // ── Shared ────────────────────────────────────────────────────────────────

  void clearAll() {
    _savedListingIds.clear();
    _likedUserIds.clear();
    notifyListeners();
  }
}
