import 'package:flutter/foundation.dart';
import 'package:mobile_delivery/models/user_data.dart';
import 'package:mobile_delivery/models/rider_data.dart';

class AuthProvider extends ChangeNotifier {
  UserData? _currentUser;
  RiderData? _currentRider;

  UserData? get currentUser => _currentUser;
  RiderData? get currentRider => _currentRider;

  bool get isUserLoggedIn => _currentUser != null;
  bool get isRiderLoggedIn => _currentRider != null;
  bool get isLoggedIn => isUserLoggedIn || isRiderLoggedIn;

  void setUser(UserData user) {
    _currentUser = user;
    _currentRider = null;
    notifyListeners();
  }

  void setRider(RiderData rider) {
    _currentRider = rider;
    _currentUser = null;
    notifyListeners();
  }

  void clear() {
    _currentUser = null;
    _currentRider = null;
    notifyListeners();
  }
}
