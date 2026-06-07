import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  UserModel? _currentUser;
  bool _preferencesSet = false;

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

  void updateSignupData(Map<String, dynamic> data) {
    _signupData.addAll(data);
    notifyListeners();
  }

  void setUserPreferences(Map<String, dynamic> preferences) {
    if (_signupData.isEmpty) return;

    // Create a new UserModel from signup data + preferences
    _currentUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: _signupData['name'] ?? 'User',
      age: preferences['age'] ?? 25,
      gender: preferences['gender'] ?? 'Not specified',
      occupation: preferences['occupation'] ?? 'Not specified',
      city: preferences['city'] ?? 'Not specified',
      bio: preferences['bio'] ?? '',
      photoUrl: preferences['photoUrl'] ?? 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
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

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _isLoading = false;
    _isAuthenticated = true;
    _currentUser = SampleData.currentUser;
    notifyListeners();
  }

  Future<void> signUp(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _isLoading = false;
    _isAuthenticated = true;
    _currentUser = SampleData.currentUser;
    notifyListeners();
  }

  Future<void> verifyOtp(String otp) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    _isLoading = false;
    notifyListeners();
  }

  void updateUserProfile(UserModel updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }

  void signOut() {
    _isAuthenticated = false;
    _currentUser = null;
    _onboardingStep = 0;
    _signupData.clear();
    _preferencesSet = false;
    notifyListeners();
  }

  void setAuthenticated(bool value) {
    _isAuthenticated = value;
    if (!value) {
      _currentUser = null;
    }
    notifyListeners();
  }
}
