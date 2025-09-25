import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_delivery/pages/login.dart';
import 'package:geolocator/geolocator.dart';

class UserRegister extends StatefulWidget {
  const UserRegister({super.key});

  @override
  State<UserRegister> createState() => _UserRegisterState();
}

class _UserRegisterState extends State<UserRegister> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();

  bool _obscure = true;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Colors
    const bg = Color(0xFFD2C2F1); // พื้นหลังม่วงอ่อน
    const cardBg = Color(0xFFF4EBFF); // พื้นการ์ด
    const borderCol = Color(0x55000000);
    const pill = Color(0xFFC9A9F5); // ปุ่มม่วงอ่อน
    const linkBlue = Color(0xFF2D72FF);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0, // ให้หน้าคลีนเหมือนภาพ
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

              // ===== User | Rider (กดไม่ได้ / แสดงผลอย่างเดียว) =====
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

              // ===== Card ฟอร์ม =====
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

                        _label('รหัสผ่าน'),
                        _input(
                          controller: _password,
                          hint: 'รหัสผ่าน',
                          obscure: _obscure,
                          suffix: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        const SizedBox(height: 14),

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

                        // กล่องแผนที่ (placeholder ตามภาพ)
                        GestureDetector(
                          onTap: () async {
                            var position = await _determinePosition();
                            log("${position.latitude} ${position.longitude}");
                          },
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: borderCol),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: const Opacity(
                              opacity: 0.45,
                              child: Icon(Icons.map, size: 36),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ปุ่มอัปโหลด/เลือกรูป (สองปุ่มเรียงกัน)
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // TODO: อัปโหลดรูปโปรไฟล์
                                  },
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
                                onPressed: () {
                                  // TODO: เลือกรูป
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black87,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text('เลือกรูป'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // ปุ่ม Submit สีดำ เต็มความกว้าง
                        SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.to(() => const LoginPage());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('ส่ง'),
                          ),
                        ),

                        const SizedBox(height: 6),

                        // ลิงก์ Sign in (เป็นปุ่มแต่เพื่อให้เหมือนภาพ กดได้หรือไม่ได้ก็ได้)
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Get.to(() => const LoginPage());
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

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
