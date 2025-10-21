import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_delivery/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  static const bg = Color(0xFFD2C2F1);
  static const cardBg = Color(0xFFF4EBFF);
  static const borderCol = Color(0x55000000);
  static const linkBlue = Color(0xFF2D72FF);

  final _addrCtrl = TextEditingController();
  final _map = MapController();
  LatLng? _center;
  final double _zoom = 15.2;
  bool _locLoading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _addrCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'เพิ่มที่อยู่ใหม่',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderCol),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'ที่อยู่',
                      style: TextStyle(
                        color: linkBlue,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _addrCtrl,
                      minLines: 3,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'รายละเอียดที่อยู่',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        const Text(
                          'แผนที่',
                          style: TextStyle(
                            color: linkBlue,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          (_center == null)
                              ? 'กำลังหาพิกัด...'
                              : 'lat: ${_center!.latitude.toStringAsFixed(6)}, lng: ${_center!.longitude.toStringAsFixed(6)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 240,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            // แผนที่
                            AbsorbPointer(
                              absorbing: _locLoading,
                              child: FlutterMap(
                                mapController: _map,
                                options: MapOptions(
                                  initialCenter: _center ?? const LatLng(0, 0),
                                  initialZoom: _zoom,
                                  onTap: (tapPos, point) {
                                    setState(() => _center = point);
                                    _map.move(point, _zoom);
                                  },
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://tile.thunderforest.com/atlas/{z}/{x}/{y}.png?apikey=6949d257c8de4157a028c7a44b05af3d',
                                    userAgentPackageName:
                                        'com.example.mobile_delivery',
                                  ),
                                  if (_center != null)
                                    MarkerLayer(
                                      markers: [
                                        Marker(
                                          point: _center!,
                                          width: 40,
                                          height: 40,
                                          child: const Icon(
                                            Icons.location_on,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            if (_locLoading)
                              const Positioned.fill(
                                child: ColoredBox(
                                  color: Colors.black12,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: _initLocation,
                          icon: const Icon(Icons.my_location),
                          label: const Text('ใช้ตำแหน่งปัจจุบัน'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black87,
                            side: const BorderSide(color: borderCol),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saving ? null : () => Get.back(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black54,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('ยกเลิก'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saving ? null : _saveAddress,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _saving
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('ยืนยัน'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _initLocation() async {
    try {
      final p = await _determinePosition();
      final c = LatLng(p.latitude, p.longitude);
      setState(() {
        _center = c;
        _locLoading = false;
      });
      _map.move(c, _zoom);
    } catch (e) {
      setState(() => _locLoading = false);
      Get.snackbar(
        'ตำแหน่ง',
        'ไม่สามารถดึงตำแหน่งได้: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services ปิดอยู่';
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'สิทธิ์ตำแหน่งถูกปฏิเสธ';
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw 'สิทธิ์ตำแหน่งถูกปฏิเสธแบบถาวร';
    }
    return Geolocator.getCurrentPosition();
  }

  Future<void> _saveAddress() async {
    final text = _addrCtrl.text.trim();
    if (text.isEmpty) {
      Get.snackbar(
        'คำเตือน',
        'กรุณากรอกรายละเอียดที่อยู่',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (_center == null) {
      Get.snackbar(
        'ตำแหน่ง',
        'ยังไม่มีพิกัด โปรดรอสักครู่หรือกดใช้ตำแหน่งปัจจุบัน',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) {
      Get.snackbar(
        'ผิดพลาด',
        'ไม่พบผู้ใช้ปัจจุบัน',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .add({
            'address': text,
            'lat': _center!.latitude,
            'lng': _center!.longitude,
            'created_at': FieldValue.serverTimestamp(),
          });

      Get.back();
      Get.snackbar(
        'สำเร็จ',
        'เพิ่มที่อยู่เรียบร้อยแล้ว',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'ผิดพลาด',
        'เพิ่มที่อยู่ไม่สำเร็จ: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
