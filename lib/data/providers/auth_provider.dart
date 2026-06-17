import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/local_db_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  UserModel? _currentUser;
  bool _preferencesSet = false;
  String? _currentEmail;

  // Onboarding state
  int _onboardingStep = 0;
  final Map<String, dynamic> _signupData = {};

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  UserModel? get currentUser => _currentUser;
  int get onboardingStep => _onboardingStep;
  Map<String, dynamic> get signupData => _signupData;
  bool get preferencesSet => _preferencesSet;

  final LocalDbService _db = LocalDbService();

  /// Call on app startup to restore session
  Future<void> tryAutoLogin() async {
    await _db.init();
    final email = _db.getCurrentSession();
    if (email == null) return;

    final userJson = _db.getUser(email);
    if (userJson == null) return;

    _currentUser = UserModel.fromJson(userJson);
    _currentEmail = email;
    _isAuthenticated = true;
    _preferencesSet = true;
    notifyListeners();
  }

  void updateSignupData(Map<String, dynamic> data) {
    _signupData.addAll(data);
    notifyListeners();
  }

  Future<void> setUserPreferences(Map<String, dynamic> preferences) async {
    if (_signupData.isEmpty) return;

    // Create a new UserModel from signup data + preferences
    _currentUser = UserModel(
      id: _currentUser?.id ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: _signupData['name'] ?? 'User',
      age: preferences['age'] ?? 25,
      gender: preferences['gender'] ?? 'Not specified',
      occupation: preferences['occupation'] ?? 'Not specified',
      city: preferences['city'] ?? 'Not specified',
      bio: preferences['bio'] ?? '',
      photoUrl: preferences['photoUrl'] ?? '',
      isVerified: false,
      rating: 0.0,
      reviewCount: 0,
      budgetRange: preferences['budgetRange'] ?? const RangeValues(800, 1500),
      preferredLocation: preferences['preferredLocation'] ?? 'Not specified',
      moveInDate: preferences['moveInDate'] ?? DateTime.now().add(const Duration(days: 30)),
      leaseDuration: preferences['leaseDuration'] ?? '12 months',
      sleepSchedule: preferences['sleepSchedule'] ?? 'flexible',
      cleanlinessLevel: preferences['cleanlinessLevel'] ?? 3,
      smoking: preferences['smoking'] ?? false,
      drinking: preferences['drinking'] ?? false,
      pets: preferences['pets'] ?? false,
      workFromHome: preferences['workFromHome'] ?? false,
      socialActivityLevel: preferences['socialActivityLevel'] ?? 3,
      guestFrequency: preferences['guestFrequency'] ?? 2,
      matches: 0,
      interests: preferences['interests'] ?? [],
    );

    _preferencesSet = true;

    // Save to local DB — MUST await to ensure data is persisted
    final email = _signupData['email'] as String?;
    final password = _signupData['password'] as String? ?? '';
    if (email != null) {
      _currentEmail = email;
      await _db.saveUserAccount(email, password, _currentUser!.toJson());
      await _db.saveCurrentSession(email);
    }

    notifyListeners();
  }

  void nextOnboardingStep() {
    _onboardingStep++;
    notifyListeners();
  }

  void previousOnboardingStep() {
    if (_onboardingStep > 0) {
      _onboardingStep--;
      notifyListeners();
    }
  }

  /// Sign in with existing credentials
  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await _db.init();
    await Future.delayed(const Duration(milliseconds: 500));

    // Check if account exists
    if (!_db.accountExists(email)) {
      _isLoading = false;
      _error = 'No account found for this email. Please sign up first.';
      notifyListeners();
      return;
    }

    final userJson = _db.verifyCredentials(email, password);
    if (userJson == null) {
      _isLoading = false;
      _error = 'Incorrect password. Please try again.';
      notifyListeners();
      return;
    }

    _currentUser = UserModel.fromJson(userJson);
    _currentEmail = email;
    _isAuthenticated = true;
    _preferencesSet = true;
    _isLoading = false;
    await _db.saveCurrentSession(email);
    notifyListeners();
  }

  /// Check if account exists
  Future<bool> checkAccountExists(String email) async {
    await _db.init();
    return _db.accountExists(email);
  }

  /// Sign up – creates account immediately so user can sign in if they drop off
  Future<void> signUp(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await _db.init();
    await Future.delayed(const Duration(milliseconds: 500));

    // Check if account already exists
    if (_db.accountExists(email)) {
      _isLoading = false;
      _error = 'An account with this email already exists. Please sign in instead.';
      notifyListeners();
      return;
    }

    _signupData['password'] = password;
    _signupData['email'] = email;
    _currentEmail = email;

    // Create a default user so they exist in DB
    _currentUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: _signupData['name'] ?? 'User',
      age: 25,
      gender: 'Not specified',
      occupation: 'Not specified',
      city: 'Not specified',
      bio: '',
      photoUrl: '',
      isVerified: false,
      rating: 0.0,
      reviewCount: 0,
      budgetRange: const RangeValues(800, 1500),
      preferredLocation: 'Not specified',
      moveInDate: DateTime.now().add(const Duration(days: 30)),
      leaseDuration: '12 months',
      sleepSchedule: 'flexible',
      cleanlinessLevel: 3,
      smoking: false,
      drinking: false,
      pets: false,
      workFromHome: false,
      socialActivityLevel: 3,
      guestFrequency: 2,
      matches: 0,
      interests: [],
    );

    await _db.saveUserAccount(email, password, _currentUser!.toJson());
    await _db.saveCurrentSession(email);
    
    _isAuthenticated = true;
    _preferencesSet = false;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateUserProfile(UserModel updatedUser) async {
    _currentUser = updatedUser;
    // Persist updated profile
    if (_currentEmail != null) {
      await _db.updateUser(_currentEmail!, updatedUser.toJson());
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    _isAuthenticated = false;
    _currentUser = null;
    _currentEmail = null;
    _onboardingStep = 0;
    _signupData.clear();
    _preferencesSet = false;
    await _db.clearSession();
    notifyListeners();
  }

  /// Reset password for the given email
  Future<String?> resetPassword(String email, String newPassword) async {
    await _db.init();
    if (!_db.accountExists(email)) {
      return 'No account found for this email.';
    }
    await _db.updatePassword(email, newPassword);
    return null; // success
  }

  void setAuthenticated(bool value) {
    _isAuthenticated = value;
    if (!value) {
      _currentUser = null;
    }
    notifyListeners();
  }

  /// Simulate Google OAuth Sign In
  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await _db.init();
    await Future.delayed(const Duration(milliseconds: 1000)); // Simulate network request

    final email = 'user.google@gmail.com';
    
    // Create account if it doesn't exist
    if (!_db.accountExists(email)) {
      _signupData['email'] = email;
      _signupData['name'] = 'Google User';
      
      _currentUser = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Google User',
        age: 25,
        gender: 'Not specified',
        occupation: 'Not specified',
        city: 'Not specified',
        bio: '',
        photoUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100',
        isVerified: true, // Google accounts are verified
        rating: 0.0,
        reviewCount: 0,
        budgetRange: const RangeValues(800, 1500),
        preferredLocation: 'Not specified',
        moveInDate: DateTime.now().add(const Duration(days: 30)),
        leaseDuration: '12 months',
        sleepSchedule: 'flexible',
        cleanlinessLevel: 3,
        smoking: false,
        drinking: false,
        pets: false,
        workFromHome: false,
        socialActivityLevel: 3,
        guestFrequency: 2,
        matches: 0,
        interests: [],
      );

      await _db.saveUserAccount(email, 'google_oauth_dummy_pass', _currentUser!.toJson());
    } else {
      final userJson = _db.getUser(email);
      if (userJson != null) {
         _currentUser = UserModel.fromJson(userJson);
      }
    }

    _currentEmail = email;
    _isAuthenticated = true;
    _preferencesSet = true; // Skip preferences for simulated google users for simplicity
    
    await _db.saveCurrentSession(email);
    
    _isLoading = false;
    notifyListeners();
  }
}
