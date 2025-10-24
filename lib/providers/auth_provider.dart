import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_delivery/models/rider_data.dart';
import 'package:mobile_delivery/models/user_data.dart';

class AuthProvider extends ChangeNotifier {
  UserData? _currentUser;
  RiderData? _currentRider;

  double? _riderLat, _riderLng;
  double? get riderLat => _riderLat;
  double? get riderLng => _riderLng;

  UserData? get currentUser => _currentUser;
  RiderData? get currentRider => _currentRider;

  StreamSubscription<Position>? _posSub;

  bool get isUserLoggedIn => _currentUser != null;
  bool get isRiderLoggedIn => _currentRider != null;
  bool get isLoggedIn => isUserLoggedIn || isRiderLoggedIn;

  void setUser(UserData user) {
    _currentUser = user;
    _currentRider = null;
    stopRiderLocationTracking();
    notifyListeners();
  }

  void setRider(RiderData rider) {
    _currentRider = rider;
    _currentUser = null;
    notifyListeners();
    startRiderLocationTracking();
  }

  void clear() {
    _currentUser = null;
    _currentRider = null;
    stopRiderLocationTracking();
    notifyListeners();
  }

  void startRiderLocationTracking() async {
    if (_currentRider == null) return;
    if (_posSub != null) return;

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever) {
      debugPrint('❌ ไม่ได้รับสิทธิ์ตำแหน่ง');
      return;
    }

    const settings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 1,
    );

    _posSub = Geolocator.getPositionStream(locationSettings: settings).listen((
      pos,
    ) async {
      _riderLat = pos.latitude;
      _riderLng = pos.longitude;
      notifyListeners();

      try {
        await FirebaseFirestore.instance
            .collection('riders')
            .doc(_currentRider!.id)
            .update({
              'lat': pos.latitude,
              'lng': pos.longitude,
              'updated_at': FieldValue.serverTimestamp(),
            });
      } catch (e) {
        debugPrint('⚠️ อัปเดตตำแหน่งล้มเหลว: $e');
      }
    });
  }

  Future<void> updateRiderLocation({
    required double lat,
    required double lng,
  }) async {
    if (_currentRider == null) return;
    _riderLat = lat;
    _riderLng = lng;
    notifyListeners();
    await FirebaseFirestore.instance
        .collection('riders')
        .doc(_currentRider!.id)
        .update({
          'lat': lat,
          'lng': lng,
          'updated_at': FieldValue.serverTimestamp(),
        });
  }

  void stopRiderLocationTracking() {
    _posSub?.cancel();
    _posSub = null;
  }
}
