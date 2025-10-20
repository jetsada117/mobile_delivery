import 'package:flutter/foundation.dart';
import 'package:mobile_delivery/models/user_data.dart';

class AuthProvider extends ChangeNotifier {
  UserData? _currentUser;
  UserData? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  void setUser(UserData user) {
    _currentUser = user;
    notifyListeners();
  }

  void clear() {
    _currentUser = null;
    notifyListeners();
  }
}
