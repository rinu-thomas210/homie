import 'package:flutter/material.dart';
import '../models/listing_model.dart';
import '../services/local_db_service.dart';

class ListingsProvider with ChangeNotifier {
  final List<ListingModel> _listings = [];
  final LocalDbService _db = LocalDbService();
  bool _initialized = false;

  List<ListingModel> get listings => List.unmodifiable(_listings);

  /// Load listings from local storage
  Future<void> loadListings() async {
    if (_initialized) return;
    await _db.init();
    final jsonList = _db.getListings();
    _listings.clear();
    for (final json in jsonList) {
      _listings.add(ListingModel.fromJson(json));
    }
    _initialized = true;
    notifyListeners();
  }

  /// Force reload listings from local storage (e.g. after sign-out/sign-in)
  Future<void> reload() async {
    _initialized = false;
    await loadListings();
  }

  Future<void> addListing(ListingModel listing) async {
    _listings.insert(0, listing);
    await _persist();
    notifyListeners();
  }

  Future<void> updateListing(ListingModel updated) async {
    final index = _listings.indexWhere((l) => l.id == updated.id);
    if (index != -1) {
      _listings[index] = updated;
      await _persist();
      notifyListeners();
    }
  }

  Future<void> removeListing(String id) async {
    _listings.removeWhere((l) => l.id == id);
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    await _db.init();
    await _db.saveListings(_listings.map((l) => l.toJson()).toList());
  }
}
