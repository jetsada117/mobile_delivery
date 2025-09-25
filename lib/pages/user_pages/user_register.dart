import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_delivery/pages/login.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';

class UserRegister extends StatefulWidget {
  const UserRegister({super.key});

  @override
  State<UserRegister> createState() => _UserRegisterState();
}

class _UserRegisterState extends State<UserRegister> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  final _confirm = TextEditingController();
  final _address = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  var db = FirebaseFirestore.instance;

  bool _obscure1 = true;
  bool _obscure2 = true;

  var mapController = MapController();
  var position;
  final double _zoom = 15.2;
  LatLng? _center;

  @override
  void initState() {
    super.initState();
    getgps();
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _phone.dispose();
    _address.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFD2C2F1);
    const cardBg = Color(0xFFF4EBFF);
    const borderCol = Color(0x55000000);
    const pill = Color(0xFFC9A9F5);
    const linkBlue = Color(0xFF2D72FF);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              const Text(
                'สมัครสมาชิก',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'ผู้ใช้',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: ' | ',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: 'ไรเดอร์',
                      style: TextStyle(
                        color: linkBlue, // สีน้ำเงินตามภาพ
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Card(
                  color: cardBg,
                  elevation: 1.2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: borderCol),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _label('ชื่อ'),
                        _input(controller: _username, hint: 'ชื่อ'),
                        const SizedBox(height: 14),

                        _label('Password'),
                        _input(
                          controller: _password,
                          hint: 'Password',
                          obscure: _obscure1,
                          suffix: IconButton(
                            icon: Icon(
                              _obscure1
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () =>
                                setState(() => _obscure1 = !_obscure1),
                          ),
                        ),
                        const SizedBox(height: 12),

                        _label('ยืนยันรหัสผ่าน'),
                        _input(
                          controller: _confirm,
                          hint: 'ยืนยันรหัสผ่าน',
                          obscure: _obscure2,
                          suffix: IconButton(
                            icon: Icon(
                              _obscure2
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () =>
                                setState(() => _obscure2 = !_obscure2),
                          ),
                        ),
                        const SizedBox(height: 12),

                        _label('เบอร์โทรศัพท์'),
                        _input(
                          controller: _phone,
                          hint: 'เบอร์โทรศัพท์',
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 14),

                        _label('ที่อยู่'),
                        _input(
                          controller: _address,
                          hint: 'รายละเอียดที่อยู่',
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),

                        Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 12),

                              SizedBox(
                                height: 240,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: FlutterMap(
                                    mapController: mapController,
                                    options: MapOptions(
                                      initialCenter:
                                          _center ?? const LatLng(0, 0),
                                      initialZoom: 15.2,
                                      onTap: (tapPosition, point) {
                                        log(point.toString());
                                      },
                                    ),
                                    children: [
                                      TileLayer(
                                        urlTemplate:
                                            'https://tile.thunderforest.com/atlas/{z}/{x}/{y}.png?apikey=6949d257c8de4157a028c7a44b05af3d',
                                        userAgentPackageName:
                                            'com.example.mobile_delivery',
                                      ),
                                      MarkerLayer(
                                        markers: [
                                          Marker(
                                            point:
                                                _center ?? const LatLng(0, 0),
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
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: pill,
                                    foregroundColor: Colors.black87,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text('อัปโหลดรูปโปรไฟล์'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 90,
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final XFile? img = await _openImagePopup(
                                    context,
                                  );
                                  if (img != null) {
                                    log('Picked: ${img.path}');
                                  } else {
                                    log('No Image');
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black87,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text('เพิ่มรูป'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: addData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('ลงทะเบียน'),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Get.back();
                            },
                            child: const Text(
                              'ยกเลิก',
                              style: TextStyle(
                                color: linkBlue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // ---- Widgets ย่อย ----
  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 13.5,
        color: Colors.black87,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _input({
    required TextEditingController controller,
    String? hint,
    bool obscure = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: suffix,
      ),
    );
  }

  Future<void> getgps() async {
    try {
      final p = await _determinePosition();
      log("${p.latitude} ${p.longitude}");

      setState(() {
        _center = LatLng(p.latitude, p.longitude);
      });

      // เลื่อนกล้องไปยังตำแหน่ง GPS
      mapController.move(_center!, _zoom);
    } catch (e) {
      log("getgps error: $e");
    }
  }

  Future<XFile?> _openImagePopup(BuildContext context) async {
    XFile? picked;

    return showDialog<XFile?>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            final double preview =
                MediaQuery.of(ctx).size.width * 0.5; // ขนาดรูปในป็อปอัพ

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: const Color(0xFFC9A9F5),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // พรีวิวรูป (แทนไอคอนกล้อง)
                    Container(
                      width: preview,
                      height: preview,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: picked == null
                          ? Icon(Icons.camera_alt, size: preview * 0.45)
                          : Image.file(File(picked!.path), fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 8),

                    // ปุ่มเปิดกล้อง
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        final x = await _picker.pickImage(
                          source: ImageSource.camera,
                        );
                        if (x != null) setLocal(() => picked = x);
                      },
                      child: const Text('เปิดกล้อง'),
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC9A9F5),
                              foregroundColor: Colors.black87,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () async {
                              final x = await _picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (x != null) setLocal(() => picked = x);
                            },
                            child: const Text('อัปโหลดรูปโปรไฟล์'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 90,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () async {
                              final x = await _picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (x != null) setLocal(() => picked = x);
                            },
                            child: const Text('เลือกรูป'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // แถว: ยกเลิก | ตกลง
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () => Navigator.pop(ctx, null),
                            child: const Text('ยกเลิก'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () => Navigator.pop(ctx, picked),
                            child: const Text('ตกลง'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> addData() async {
    if (_username.text.isEmpty ||
        _phone.text.isEmpty ||
        _password.text.isEmpty ||
        _confirm.text.isEmpty ||
        _address.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("กรอกข้อมูลไม่ครบ"),
          content: Text("กรุณากรอกข้อมูลทุกช่องให้ครบถ้วน"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("ตกลง"),
            ),
          ],
        ),
      );
      return;
    }

    if (_password.text != _confirm.text) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("รหัสผ่านไม่ตรงกัน"),
          content: Text("กรุณากรอกรหัสผ่านให้ตรงกัน"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("ตกลง"),
            ),
          ],
        ),
      );
      return;
    }

    final collection = FirebaseFirestore.instance.collection('user');
    final snapshot = await collection.count().get();
    int userId = snapshot.count! + 1;

    var data = {
      'name': _username.text,
      'phone': _phone.text,
      'password': _password.text,
      'user_image': "",
    };

    var address = {
      'address': _address.text,
      'lat': _center?.latitude,
      'lng': _center?.longitude,
    };

    await db.collection('user').doc(userId.toString()).set(data);

    await db
        .collection('user')
        .doc(userId.toString())
        .collection('address')
        .add(address);

    log("User: $data");
    log("Address: $address");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("สำเร็จ"),
        content: Text("เพิ่มข้อมูล User เรียบร้อยแล้ว"),
        actions: [
          TextButton(
            onPressed: () {
              Get.to(() => LoginPage());
            },
            child: Text("ตกลง"),
          ),
        ],
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return await Geolocator.getCurrentPosition();
  }
}
