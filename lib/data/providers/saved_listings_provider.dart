import 'package:flutter/material.dart';
import '../services/local_db_service.dart';

class SavedListingsProvider with ChangeNotifier {
  // Saved property listing IDs
  final Set<String> _savedListingIds = {};

  // Liked / wishlisted roommate user IDs
  final Set<String> _likedUserIds = {};

  final LocalDbService _db = LocalDbService();
  bool _initialized = false;

  /// Load saved data from local storage
  Future<void> loadSaved() async {
    if (_initialized) return;
    await _db.init();
    _savedListingIds.addAll(_db.getSavedListingIds());
    _likedUserIds.addAll(_db.getLikedUserIds());
    _initialized = true;
    notifyListeners();
  }

  // ── Listings ──────────────────────────────────────────────────────────────

  Set<String> get savedListingIds => _savedListingIds;

  bool isSaved(String listingId) => _savedListingIds.contains(listingId);

  void toggleSave(String listingId) {
    if (_savedListingIds.contains(listingId)) {
      _savedListingIds.remove(listingId);
    } else {
      _savedListingIds.add(listingId);
    }
    _persistSaved();
    notifyListeners();
  }

  void saveListings(String listingId) {
    _savedListingIds.add(listingId);
    _persistSaved();
    notifyListeners();
  }

  void removeSavedListing(String listingId) {
    _savedListingIds.remove(listingId);
    _persistSaved();
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
    _persistLiked();
    notifyListeners();
  }

  void likeUser(String userId) {
    _likedUserIds.add(userId);
    _persistLiked();
    notifyListeners();
  }

  void unlikeUser(String userId) {
    _likedUserIds.remove(userId);
    _persistLiked();
    notifyListeners();
  }

  // ── Shared ────────────────────────────────────────────────────────────────

  void clearAll() {
    _savedListingIds.clear();
    _likedUserIds.clear();
    _persistSaved();
    _persistLiked();
    notifyListeners();
  }

  // ── Persistence ───────────────────────────────────────────────────────────

  Future<void> _persistSaved() async {
    await _db.init();
    await _db.saveSavedListingIds(_savedListingIds.toList());
  }

  Future<void> _persistLiked() async {
    await _db.init();
    await _db.saveLikedUserIds(_likedUserIds.toList());
  }
}
