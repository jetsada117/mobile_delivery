import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_delivery/pages/login.dart';

class RiderRegister extends StatefulWidget {
  const RiderRegister({super.key});

  @override
  State<RiderRegister> createState() => _RiderRegisterState();
}

class _RiderRegisterState extends State<RiderRegister> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _phone = TextEditingController();
  final _plate = TextEditingController();

  bool _obscure1 = true;
  bool _obscure2 = true;

  var db = FirebaseFirestore.instance;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _confirm.dispose();
    _phone.dispose();
    _plate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFD2C2F1);
    const cardBg = Color(0xFFF4EBFF);
    const linkBlue = Color(0xFF2D72FF);
    const borderCol = Color(0x55000000);

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
            children: [
              const SizedBox(height: 8),
              const Text(
                'สมัครสมาชิก',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),

              // User | Rider (แสดงเฉยๆ กดไม่ได้)
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'ผู้ใช้',
                      style: TextStyle(
                        color: Color(0xFF69A2FF), // ฟ้าอ่อนทึบตามภาพ
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
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // การ์ดฟอร์ม
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
                        const SizedBox(height: 12),

                        _label('รหัสผ่าน'),
                        _input(
                          controller: _password,
                          hint: 'รหัสผ่าน',
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
                        const SizedBox(height: 12),

                        _label('ทะเบียนรถ'),
                        _input(controller: _plate, hint: 'ทะเบียนรถ'),
                        const SizedBox(height: 12),

                        // ปุ่มอัปโหลดรูปโปรไฟล์
                        _uploadRow(
                          caption: 'อัปโหลดรูปโปรไฟล์',
                          onPick: () {
                            // TODO: เลือกรูปโปรไฟล์
                          },
                        ),
                        const SizedBox(height: 8),

                        // ปุ่มอัปโหลดรูปยานพาหนะ
                        _uploadRow(
                          caption: 'อัปโหลดรูปยานพาหนะ',
                          onPick: () {
                            // TODO: เลือกรูปรถ
                          },
                        ),
                        const SizedBox(height: 14),

                        // Submit
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

  Widget _uploadRow({required String caption, required VoidCallback onPick}) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC9A9F5),
                foregroundColor: Colors.black87,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(caption),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // ปุ่มขวา (ดำ เล็ก)
        SizedBox(
          width: 72,
          height: 40,
          child: ElevatedButton(
            onPressed: onPick,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('เพิ่มรูป', style: TextStyle(fontSize: 13)),
          ),
        ),
      ],
    );
  }

  Future<void> addData() async {
    if (_username.text.isEmpty ||
        _phone.text.isEmpty ||
        _password.text.isEmpty ||
        _confirm.text.isEmpty ||
        _plate.text.isEmpty) {
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

    final collection = FirebaseFirestore.instance.collection('rider');
    final snapshot = await collection.count().get();
    int newId = snapshot.count! + 1;

    var data = {
      'name': _username.text,
      'phone': _phone.text,
      'password': _password.text,
      'plate_no': _plate.text,
      'lat': "",
      'lng': "",
      'vihicle_image': "",
      'rider_image': "",
    };

    log(data.toString());
    db.collection('rider').doc(newId.toString()).set(data);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("สำเร็จ"),
        content: Text("เพิ่มข้อมูล Rider เรียบร้อยแล้ว"),
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
}
