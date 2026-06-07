import 'package:flutter/foundation.dart';

class AppProvider with ChangeNotifier {
  int _currentNavIndex = 0;
  bool _isDarkMode = false;

  int get currentNavIndex => _currentNavIndex;
  bool get isDarkMode => _isDarkMode;

  void setNavIndex(int index) {
    _currentNavIndex = index;
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }
}


