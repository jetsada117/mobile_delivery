import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_delivery/models/user_data.dart';
import 'package:mobile_delivery/models/rider_data.dart';

class AuthProvider extends ChangeNotifier {
  UserData? _currentUser;
  RiderData? _currentRider;

  UserData? get currentUser => _currentUser;
  RiderData? get currentRider => _currentRider;
  Stream<Position>? _posStream;
  StreamSubscription<Position>? _posSub;

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

  void startRiderLocationTracking() async {
    if (currentRider == null) return;

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

    _posSub?.cancel();
    _posStream = Geolocator.getPositionStream(locationSettings: settings);
    _posSub = _posStream!.listen((pos) async {
      try {
        await FirebaseFirestore.instance
            .collection('riders')
            .doc(currentRider!.id)
            .update({
              'lat': pos.latitude,
              'lng': pos.longitude,
              'updated_at': FieldValue.serverTimestamp(),
            });
        debugPrint('✅ อัปเดตตำแหน่งไรเดอร์: ${pos.latitude}, ${pos.longitude}');
      } catch (e) {
        debugPrint('⚠️ อัปเดตตำแหน่งล้มเหลว: $e');
      }
    });
  }

  void stopRiderLocationTracking() {
    _posSub?.cancel();
    _posSub = null;
    debugPrint('🛑 หยุดติดตามตำแหน่งไรเดอร์');
  }
}
