import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_delivery/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class RiderDeliveryStatusPage extends StatefulWidget {
  final String orderId;
  const RiderDeliveryStatusPage({super.key, required this.orderId});

  @override
  State<RiderDeliveryStatusPage> createState() =>
      _RiderDeliveryStatusPageState();
}

class _RiderDeliveryStatusPageState extends State<RiderDeliveryStatusPage> {
  static const bg = Color(0xFFD2C2F1);
  static const cardBg = Color(0xFFF4EBFF);
  static const borderCol = Color(0x55000000);
  final MapController _mapController = MapController();

  final _picker = ImagePicker();

  LatLng? riderPos;
  LatLng? senderPos;
  LatLng? receiverPos;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadPositions();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String? _pathFrom(dynamic v) {
    if (v == null) return null;
    if (v is DocumentReference) return v.path;
    if (v is String) return v;
    return null;
  }

  Future<LatLng?> _latLngFromPath(String path) async {
    final snap = await FirebaseFirestore.instance.doc(path).get();
    if (!snap.exists) return null;
    final m = snap.data() as Map<String, dynamic>;
    final lat = (m['lat'] as num?)?.toDouble();
    final lng = (m['lng'] as num?)?.toDouble();
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context
        .watch<AuthProvider>(); // 👈 ใช้ watch เพื่อ reactive update
    final providerRiderPos = (auth.riderLat != null && auth.riderLng != null)
        ? LatLng(auth.riderLat!, auth.riderLng!)
        : null;

    if (loading) {
      return const Scaffold(
        backgroundColor: bg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final initialCenter =
        providerRiderPos ??
        senderPos ??
        receiverPos ??
        const LatLng(16.2458, 103.25);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'สถานะการส่ง',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 14.5,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.thunderforest.com/atlas/{z}/{x}/{y}.png?apikey=6949d257c8de4157a028c7a44b05af3d',
                userAgentPackageName: 'com.example.mobile_delivery',
              ),
              MarkerLayer(markers: _buildMarkers(providerRiderPos)),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderCol),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatusPill(
                      icon: Icons.location_on_outlined,
                      iconColor: Colors.green,
                    ),
                    _StatusPill(icon: Icons.check_circle_outline),
                    _StatusPill(icon: Icons.local_shipping_outlined),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            bottom: 140,
            child: _CameraButton(
              onTap: () => _openProofPopup(context, 'รับออเดอร์'),
            ),
          ),
          Positioned(
            right: 24,
            bottom: 140,
            child: _CameraButton(
              onTap: () => _openProofPopup(context, 'จัดส่งสำเร็จ'),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderCol),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: const [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/100?img=12',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ข้อมูลผู้รับ',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 4),
                        Text('ชื่อ: นายสมชาย เด็กดี'),
                        Text('เบอร์โทร: 012-345-6789'),
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

  List<Marker> _buildMarkers(LatLng? riderLivePos) {
    final markers = <Marker>[];

    if (senderPos != null) {
      markers.add(
        Marker(
          point: senderPos!,
          width: 36,
          height: 36,
          child: const Icon(Icons.store, size: 32, color: Colors.orange),
        ),
      );
    }

    if (receiverPos != null) {
      markers.add(
        Marker(
          point: receiverPos!,
          width: 36,
          height: 36,
          child: const Icon(Icons.home, size: 32, color: Colors.green),
        ),
      );
    }

    if (riderLivePos != null) {
      markers.add(
        Marker(
          point: riderLivePos,
          width: 40,
          height: 40,
          child: const Icon(
            Icons.delivery_dining,
            size: 36,
            color: Colors.black87,
          ),
        ),
      );
    }

    return markers;
  }

  Future<void> _openProofPopup(BuildContext context, String title) async {
    XFile? picked;
    final nameController = TextEditingController();

    final bool? ok = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          final blackBtnStyle = ElevatedButton.styleFrom(
            backgroundColor: Colors.black87,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          );

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: const Color(0xFFC9A9F5),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final x = await _picker.pickImage(
                        source: ImageSource.camera,
                      );
                      if (x != null) {
                        setLocal(() {
                          picked = x;
                          nameController.text = x.name;
                        });
                      }
                    },
                    child: Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: picked == null
                          ? const Icon(
                              Icons.photo_camera_outlined,
                              size: 40,
                              color: Colors.black87,
                            )
                          : Image.file(File(picked!.path), fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: nameController,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: 'ชื่อรูป',
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () async {
                            final x = await _picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (x != null) {
                              setLocal(() {
                                picked = x;
                                nameController.text = x.name;
                              });
                            }
                          },
                          style: blackBtnStyle,
                          child: const Text('อัปโหลดรูปภาพ'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 96,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          style: blackBtnStyle,
                          child: const Text('ยกเลิก'),
                        ),
                      ),
                      SizedBox(
                        width: 96,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: blackBtnStyle,
                          child: const Text('ยืนยัน'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    if (ok == true && context.mounted) {
      if (picked == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณาถ่ายหรืออัปโหลดรูปก่อน')),
        );
        return;
      }
    }
  }

  Future<void> _loadPositions() async {
    try {
      final auth = context.read<AuthProvider>();
      LatLng? rider;

      if (auth.riderLat != null && auth.riderLng != null) {
        rider = LatLng(auth.riderLat!, auth.riderLng!);
      } else {
        final p = await Geolocator.getCurrentPosition();
        rider = LatLng(p.latitude, p.longitude);
      }

      final orderDoc = await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .get();

      if (!orderDoc.exists) throw 'ไม่พบออเดอร์ ${widget.orderId}';

      final data = orderDoc.data()!;
      final sendAtPath = _pathFrom(data['send_at']);
      final receiveAtPath = _pathFrom(data['receive_at']);

      LatLng? s, r;
      if (sendAtPath != null && sendAtPath.isNotEmpty) {
        s = await _latLngFromPath(sendAtPath);
      }
      if (receiveAtPath != null && receiveAtPath.isNotEmpty) {
        r = await _latLngFromPath(receiveAtPath);
      }

      if (!mounted) return;
      setState(() {
        riderPos = rider;
        senderPos = s;
        receiverPos = r;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('โหลดตำแหน่งไม่สำเร็จ: $e')));
    }
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.icon, this.iconColor = Colors.black87});
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color(0x55000000)),
      ),
      child: Icon(icon, size: 20, color: iconColor),
    );
  }
}

class _CameraButton extends StatelessWidget {
  const _CameraButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 74,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFC9A9F5),
          foregroundColor: Colors.black87,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Icon(Icons.photo_camera_outlined, size: 26),
      ),
    );
  }
}
