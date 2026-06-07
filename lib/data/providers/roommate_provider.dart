import 'package:flutter/material.dart';

class RoommateProvider with ChangeNotifier {
  String? _rentedListingId;
  final List<String> _roommateIds = [];
  final List<String> _pendingSentRequests = [];
  // Pre-seed an incoming request from Alex Rivera (id: '1') to test the acceptance flow
  final List<String> _pendingReceivedRequests = ['1'];
  final List<String> _requestedListingIds = [];

  String? get rentedListingId => _rentedListingId;
  List<String> get roommateIds => List.unmodifiable(_roommateIds);
  List<String> get pendingSentRequests => List.unmodifiable(_pendingSentRequests);
  List<String> get pendingReceivedRequests => List.unmodifiable(_pendingReceivedRequests);
  List<String> get requestedListingIds => List.unmodifiable(_requestedListingIds);

  bool get hasRentedRoom => _rentedListingId != null;
  bool hasRequestedListing(String listingId) => _requestedListingIds.contains(listingId);

  void requestListing(String listingId) {
    if (hasRentedRoom) return;
    if (!_requestedListingIds.contains(listingId)) {
      _requestedListingIds.add(listingId);
      notifyListeners();
    }
  }

  void cancelListingRequest(String listingId) {
    _requestedListingIds.remove(listingId);
    notifyListeners();
  }

  void acceptListingRequest(String listingId, List<String> listingRoommateIds) {
    _rentedListingId = listingId;
    _requestedListingIds.clear(); // Deny all other requests
    for (final id in listingRoommateIds) {
      if (!_roommateIds.contains(id)) {
        _roommateIds.add(id);
      }
    }
    notifyListeners();
  }

  void rentListing(String listingId) {
    _rentedListingId = listingId;
    _requestedListingIds.clear();
    notifyListeners();
  }

  void cancelRental() {
    _rentedListingId = null;
    _roommateIds.clear();
    notifyListeners();
  }

  void sendRoommateRequest(String userId) {
    if (!_pendingSentRequests.contains(userId) && !_roommateIds.contains(userId)) {
      _pendingSentRequests.add(userId);
      notifyListeners();
    }
  }

  void cancelRoommateRequest(String userId) {
    _pendingSentRequests.remove(userId);
    notifyListeners();
  }

  void acceptRoommateRequest(String userId) {
    _pendingReceivedRequests.remove(userId);
    _pendingSentRequests.remove(userId);
    if (!_roommateIds.contains(userId)) {
      _roommateIds.add(userId);
    }
    notifyListeners();
  }

  void rejectRoommateRequest(String userId) {
    _pendingReceivedRequests.remove(userId);
    notifyListeners();
  }

  void removeRoommate(String userId) {
    _roommateIds.remove(userId);
    notifyListeners();
  }

  bool isRoommate(String userId) => _roommateIds.contains(userId);
  bool hasSentRequest(String userId) => _pendingSentRequests.contains(userId);
  bool hasReceivedRequest(String userId) => _pendingReceivedRequests.contains(userId);
}
