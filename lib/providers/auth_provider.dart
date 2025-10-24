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
    stopRiderLocationTracking();
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
    stopRiderLocationTracking();
    _currentUser = null;
    _currentRider = null;
    notifyListeners();
  }

  void startRiderLocationTracking() async {
    // ไม่มีไรเดอร์ก็ไม่ต้องเริ่ม
    if (_currentRider == null) return;

    // ถ้ามีสตรีมเก่าอยู่ ให้ปิดก่อนเพื่อความชัวร์
    await _posSub?.cancel();
    _posSub = null;

    // ตรวจสิทธิ์ตำแหน่ง
    var perm = await Geolocator.checkPermission();
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

    _posSub = Geolocator.getPositionStream(locationSettings: settings).listen(
      (pos) async {
        // อัปเดตค่าใน provider ให้ UI ใช้
        _riderLat = pos.latitude;
        _riderLng = pos.longitude;
        notifyListeners();

        // กัน null แบบปลอดภัยทุกครั้งก่อนยิงขึ้น Firestore
        final rid = _currentRider?.id;
        if (rid == null) {
          // ถูกสลับบทบาท/ล็อกเอาต์ระหว่างสตรีม → หยุดสตรีม
          debugPrint('ℹ️ currentRider ว่างระหว่างอัปเดตตำแหน่ง: หยุดติดตาม');
          await _posSub?.cancel();
          _posSub = null;
          return;
        }

        try {
          await FirebaseFirestore.instance
              .collection('riders')
              .doc(rid)
              .update({
                'lat': pos.latitude,
                'lng': pos.longitude,
                'updated_at': FieldValue.serverTimestamp(),
              });
        } catch (e) {
          debugPrint('⚠️ อัปเดตตำแหน่งล้มเหลว: $e');
        }
      },
      onError: (e) => debugPrint('⚠️ สตรีมตำแหน่ง error: $e'),
      cancelOnError: false,
    );
  }

  Future<void> updateRiderLocation(Position pos) async {
    final rid = currentRider?.id;
    if (rid == null) {
      debugPrint('⚠️ currentRider ยังไม่มีข้อมูล ข้ามการอัปเดตตำแหน่ง');
      return;
    }
    await FirebaseFirestore.instance.collection('riders').doc(rid).update({
      'lat': pos.latitude,
      'lng': pos.longitude,
      'updated_at': FieldValue.serverTimestamp(),
    });
    debugPrint('✅ อัปเดตตำแหน่งไรเดอร์เรียบร้อย');
  }

  void stopRiderLocationTracking() {
    _posSub?.cancel();
    _posSub = null;
    debugPrint('🛑 หยุดติดตามตำแหน่งไรเดอร์');
  }
}
