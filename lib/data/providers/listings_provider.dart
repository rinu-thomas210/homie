import 'package:flutter/material.dart';
import '../models/listing_model.dart';

class ListingsProvider with ChangeNotifier {
  final List<ListingModel> _listings = List.from(SampleListings.listings);

  List<ListingModel> get listings => List.unmodifiable(_listings);

  void addListing(ListingModel listing) {
    _listings.insert(0, listing);
    notifyListeners();
  }
}
