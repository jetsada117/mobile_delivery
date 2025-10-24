// lib/pages/user_pages/user_rider_map.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RiderMapPage extends StatefulWidget {
  const RiderMapPage({
    super.key,
    required this.orderId,
    required this.senderLatLng,
    required this.receiverLatLng,
  });

  final String orderId;
  final LatLng senderLatLng;
  final LatLng receiverLatLng;

  @override
  State<RiderMapPage> createState() => _RiderMapPageState();
}

class _RiderMapPageState extends State<RiderMapPage> {
  static const bg = Color(0xFFD2C2F1);

  // ✅ เพิ่ม controller
  final MapController _mapController = MapController();

  // ข้อมูลไรเดอร์
  LatLng? _riderLatLng;
  String? _riderName;
  String? _riderPhone;
  String? _riderPlate;
  String? _riderAvatarUrl;

  int _currentStatus = 0;
  String get _statusText {
    switch (_currentStatus) {
      case 1:
        return 'รอไรเดอร์รับงาน';
      case 2:
        return 'ไรเดอร์กำลังมารับสินค้า';
      case 3:
        return 'กำลังจัดส่ง';
      case 4:
        return 'จัดส่งสำเร็จ';
      default:
        return '-';
    }
  }

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _orderSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _riderSub;
  final _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _listenOrderAndRider();
  }

  @override
  void dispose() {
    _orderSub?.cancel();
    _riderSub?.cancel();
    super.dispose();
  }

  void _listenOrderAndRider() {
    _orderSub = _db.collection('orders').doc(widget.orderId).snapshots().listen(
      (snap) {
        if (!snap.exists) return;

        final data = snap.data()!;
        final riderId = data['rider_id'] as String?;
        final st = (data['current_status'] ?? 0) as int;

        if (mounted) setState(() => _currentStatus = st);

        if (riderId != null && riderId.isNotEmpty) {
          _listenRider(riderId);
        } else {
          _riderSub?.cancel();
          if (mounted) {
            setState(() {
              _riderLatLng = null;
              _riderName = null;
              _riderPhone = null;
              _riderPlate = null;
              _riderAvatarUrl = null;
            });
          }
        }
      },
    );
  }

  // ✅ ฟังตำแหน่งไรเดอร์ และขยับ marker + กล้อง
  void _listenRider(String riderId) {
    _riderSub?.cancel();
    _riderSub = _db.collection('riders').doc(riderId).snapshots().listen((
      snap,
    ) {
      if (!snap.exists) return;
      final r = snap.data()!;
      final lat = (r['lat'] as num?)?.toDouble();
      final lng = (r['lng'] as num?)?.toDouble();

      if (lat != null && lng != null) {
        final newPos = LatLng(lat, lng);
        if (mounted) {
          setState(() {
            _riderLatLng = newPos;
            _riderName = r['name'] as String?;
            _riderPhone = r['phone'] as String?;
            _riderPlate = r['plate_no'] as String?;
            _riderAvatarUrl = r['rider_image'] as String?;
          });

          // ✅ ขยับกล้องไปยังตำแหน่งไรเดอร์ใหม่แบบ smooth
          try {
            final zoom = _mapController.camera.zoom;
            _mapController.move(newPos, zoom);
          } catch (_) {}
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final middle = LatLng(
      (widget.senderLatLng.latitude + widget.receiverLatLng.latitude) / 2,
      (widget.senderLatLng.longitude + widget.receiverLatLng.longitude) / 2,
    );

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text(
          'แผนที่',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController, // ✅ ผูก controller
            options: MapOptions(
              initialCenter: _riderLatLng ?? middle,
              initialZoom: 13.5,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.thunderforest.com/atlas/{z}/{x}/{y}.png?apikey=6949d257c8de4157a028c7a44b05af3d',
                userAgentPackageName: 'com.example.mobile_delivery',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: widget.senderLatLng,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.storefront,
                      color: Colors.green,
                      size: 36,
                    ),
                  ),
                  Marker(
                    point: widget.receiverLatLng,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.home,
                      color: Colors.blueAccent,
                      size: 36,
                    ),
                  ),
                  if (_riderLatLng != null)
                    Marker(
                      point: _riderLatLng!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.delivery_dining,
                        color: Colors.redAccent,
                        size: 40,
                      ),
                    ),
                ],
              ),
            ],
          ),

          // ✅ Legend
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.storefront, color: Colors.green, size: 18),
                  const SizedBox(width: 4),
                  const Text('ผู้ส่ง'),
                  const SizedBox(width: 8),
                  if (_riderLatLng != null) ...[
                    const Icon(
                      Icons.delivery_dining,
                      color: Colors.redAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    const Text('ไรเดอร์'),
                    const SizedBox(width: 8),
                  ],
                  const Icon(Icons.home, color: Colors.blueAccent, size: 18),
                  const SizedBox(width: 4),
                  const Text('ผู้รับ'),
                ],
              ),
            ),
          ),

          // ✅ ข้อมูลไรเดอร์
          if (_riderLatLng != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF4EBFF),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          (_riderAvatarUrl != null &&
                              _riderAvatarUrl!.isNotEmpty)
                          ? NetworkImage(_riderAvatarUrl!)
                          : null,
                      child:
                          (_riderAvatarUrl == null || _riderAvatarUrl!.isEmpty)
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ข้อมูลไรเดอร์',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Text('ชื่อ : ${_riderName ?? '-'}'),
                              ),
                              Text('สถานะ: $_statusText'),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text('เบอร์โทร : ${_riderPhone ?? '-'}'),
                          const SizedBox(height: 2),
                          Text('ทะเบียนรถ : ${_riderPlate ?? '-'}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
