import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_delivery/pages/rider_pages/rider_home.dart';
import 'package:mobile_delivery/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final supa = Supabase.instance.client;
  int currentStatus = 0;

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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatusPill(
                      icon: Icons.location_on_outlined,
                      iconColor: currentStatus == 2
                          ? Colors.yellow
                          : Colors.grey[800]!,
                    ),
                    _StatusPill(
                      icon: Icons.check_circle_outline,
                      iconColor: currentStatus == 3
                          ? Colors.yellow
                          : Colors.grey[800]!,
                    ),
                    _StatusPill(
                      icon: Icons.local_shipping_outlined,
                      iconColor: currentStatus == 4
                          ? Colors.yellow
                          : Colors.grey[800]!,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 24,
            bottom: 140,
            child: _CameraButton(
              onTap: () => _openProofPopup(context, 'อัปโหลดภาพ'),
            ),
          ),

          if (currentStatus == 4)
            Positioned(
              left: 20,
              right: 20,
              bottom: 80,
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.flag_circle_outlined),
                  label: const Text(
                    'จบออเดอร์',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[700],
                    foregroundColor: Colors.black,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      final orderRef = FirebaseFirestore.instance
                          .collection('orders')
                          .doc(widget.orderId);

                      await orderRef.update({
                        'is_active': false,
                        'current_status': 4,
                        'updated_at': FieldValue.serverTimestamp(),
                      });

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('ออเดอร์เสร็จสิ้นแล้ว ✅'),
                          ),
                        );
                        Get.to(() => RiderHomePage());
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
                      );
                    }
                  },
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

      final auth = context.read<AuthProvider>();
      final rider = auth.currentRider;
      if (rider == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ไม่พบข้อมูลไรเดอร์')));
        return;
      }

      final orderRef = FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId);

      try {
        // 1) อ่านสถานะล่าสุดเพื่อกันเคสซิงก์
        final snap = await orderRef.get();
        final int cur = (snap.data()?['current_status'] ?? 2) as int;
        final int nextStatus = _nextPhotoStatus(cur);

        // 2) อัปโหลดภาพ แล้วบันทึกลง delivery_photos ด้วยสถานะเดียวกัน (3 หรือ 4)
        await _uploadDeliveryPhotoFromLocalFile(
          filePath: picked!.path,
          orderId: widget.orderId, // ไม่ต้อง parse เป็น int
          uploaderUid: rider.id,
          status: nextStatus,
        );

        // 3) อัปเดตสถานะออเดอร์เป็น nextStatus (ไม่ใช่ +1 แบบเดิม)
        await orderRef.update({
          'current_status': nextStatus,
          'updated_at': FieldValue.serverTimestamp(),
        });

        // 4) รีเฟรชไฮไลท์ทันที
        if (mounted) {
          setState(() => currentStatus = nextStatus);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('อัปโหลดสำเร็จ (สถานะ = $nextStatus)')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาดในการอัปโหลด: $e')),
        );
      }
    }
  }

  Future<String> _uploadDeliveryPhotoFromLocalFile({
    required String filePath,
    required String orderId, // เดิมเป็น int
    required String uploaderUid,
    required int status,
  }) async {
    final fileBytes = await File(filePath).readAsBytes();

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final objectPath = 'delivery_photos/$orderId/$fileName';

    await supa.storage
        .from('delivery')
        .uploadBinary(
          objectPath,
          fileBytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

    final publicUrl = supa.storage.from('delivery').getPublicUrl(objectPath);

    await FirebaseFirestore.instance.collection('delivery_photos').add({
      'image_url': publicUrl,
      'order_id': orderId, // String ได้เลย
      'status': status,
      'upload_by': uploaderUid,
      'created_at': FieldValue.serverTimestamp(),
    });

    return publicUrl;
  }

  Future<void> _loadPositions() async {
    try {
      final auth = context.read<AuthProvider>();
      final riderData = auth.currentRider;
      if (riderData == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ไม่พบข้อมูลไรเดอร์')));
        return;
      }

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
      final int status = (data['current_status'] ?? 0) as int;

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
        currentStatus = status;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('โหลดตำแหน่งไม่สำเร็จ: $e')));
    }
  }

  int _nextPhotoStatus(int current) {
    // [1]รอรับ → อัพรูปครั้งแรก = 3, ครั้งถัดไป = 4
    // [2]กำลังไปรับ → อัพรูปครั้งแรก = 3, ครั้งถัดไป = 4
    // [3]รับแล้ว → อัพรูปครั้งถัดไป = 4
    // [4]ส่งแล้ว → คง 4
    if (current < 3) return 3;
    if (current == 3) return 4;
    return 4;
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
