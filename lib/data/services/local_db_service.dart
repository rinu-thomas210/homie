import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// A singleton service that wraps SharedPreferences to provide
/// persistent local storage for the Homie app.
class LocalDbService {
  static final LocalDbService _instance = LocalDbService._internal();
  factory LocalDbService() => _instance;
  LocalDbService._internal();

  SharedPreferences? _prefs;

  // Keys
  static const String _keyCurrentUserId = 'current_user_id';
  static const String _keyUsers = 'users'; // Map<email, userJson>
  static const String _keyPasswords = 'passwords'; // Map<email, password>
  static const String _keyListings = 'listings'; // List<listingJson>
  static const String _keyReviews = 'reviews'; // List<reviewJson>
  static const String _keySavedListingIds = 'saved_listing_ids';
  static const String _keyLikedUserIds = 'liked_user_ids';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── User Account Management ──────────────────────────────────────────────

  /// Save a user account (email -> user JSON & password)
  Future<void> saveUserAccount(String email, String password, Map<String, dynamic> userJson) async {
    final users = _getMap(_keyUsers);
    users[email] = jsonEncode(userJson);
    await _prefs!.setString(_keyUsers, jsonEncode(users));

    final passwords = _getMap(_keyPasswords);
    passwords[email] = password;
    await _prefs!.setString(_keyPasswords, jsonEncode(passwords));
  }

  /// Check if an account exists for the given email
  bool accountExists(String email) {
    final users = _getMap(_keyUsers);
    return users.containsKey(email);
  }

  /// Verify credentials and return user JSON if valid, null otherwise
  Map<String, dynamic>? verifyCredentials(String email, String password) {
    final passwords = _getMap(_keyPasswords);
    if (passwords[email] != password) return null;

    final users = _getMap(_keyUsers);
    final userStr = users[email];
    if (userStr == null) return null;

    return jsonDecode(userStr) as Map<String, dynamic>;
  }

  /// Update the stored user data for a given email
  Future<void> updateUser(String email, Map<String, dynamic> userJson) async {
    final users = _getMap(_keyUsers);
    users[email] = jsonEncode(userJson);
    await _prefs!.setString(_keyUsers, jsonEncode(users));
  }

  /// Update the stored password for a given email
  Future<void> updatePassword(String email, String newPassword) async {
    final passwords = _getMap(_keyPasswords);
    passwords[email] = newPassword;
    await _prefs!.setString(_keyPasswords, jsonEncode(passwords));
  }

  /// Get the user JSON for a given email
  Map<String, dynamic>? getUser(String email) {
    final users = _getMap(_keyUsers);
    final userStr = users[email];
    if (userStr == null) return null;
    return jsonDecode(userStr) as Map<String, dynamic>;
  }

  /// Get the user JSON for a given ID
  Map<String, dynamic>? getUserById(String id) {
    final users = _getMap(_keyUsers);
    for (final userStr in users.values) {
      final userJson = jsonDecode(userStr) as Map<String, dynamic>;
      if (userJson['id'] == id) {
        return userJson;
      }
    }
    return null;
  }

  // ── Session Management ─────────────────────────────────────────────────

  /// Save the current logged-in user's email
  Future<void> saveCurrentSession(String email) async {
    await _prefs!.setString(_keyCurrentUserId, email);
  }

  /// Get the currently logged-in user's email (null if not logged in)
  String? getCurrentSession() {
    return _prefs!.getString(_keyCurrentUserId);
  }

  /// Clear the current session (logout)
  Future<void> clearSession() async {
    await _prefs!.remove(_keyCurrentUserId);
  }

  // ── Listings ───────────────────────────────────────────────────────────

  Future<void> saveListings(List<Map<String, dynamic>> listings) async {
    await _prefs!.setString(_keyListings, jsonEncode(listings));
  }

  List<Map<String, dynamic>> getListings() {
    final str = _prefs!.getString(_keyListings);
    if (str == null) return [];
    final list = jsonDecode(str) as List;
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // ── Reviews ────────────────────────────────────────────────────────────

  Future<void> saveReviews(List<Map<String, dynamic>> reviews) async {
    await _prefs!.setString(_keyReviews, jsonEncode(reviews));
  }

  List<Map<String, dynamic>> getReviews() {
    final str = _prefs!.getString(_keyReviews);
    if (str == null) return [];
    final list = jsonDecode(str) as List;
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // ── Saved Listings & Liked Users ───────────────────────────────────────

  Future<void> saveSavedListingIds(List<String> ids) async {
    await _prefs!.setStringList(_keySavedListingIds, ids);
  }

  List<String> getSavedListingIds() {
    return _prefs!.getStringList(_keySavedListingIds) ?? [];
  }

  Future<void> saveLikedUserIds(List<String> ids) async {
    await _prefs!.setStringList(_keyLikedUserIds, ids);
  }

  List<String> getLikedUserIds() {
    return _prefs!.getStringList(_keyLikedUserIds) ?? [];
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  Map<String, dynamic> _getMap(String key) {
    final str = _prefs!.getString(key);
    if (str == null) return {};
    return Map<String, dynamic>.from(jsonDecode(str) as Map);
  }
}
