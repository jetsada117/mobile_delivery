import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_delivery/pages/login.dart';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

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
  final ImagePicker _picker = ImagePicker();

  bool _obscure1 = true;
  bool _obscure2 = true;

  var db = FirebaseFirestore.instance;
  final supa = Supabase.instance.client;

  XFile? _riderImg; // ⬅️ รูปโปรไฟล์ไรเดอร์
  XFile? _vehicleImg; // ⬅️ รูปยานพาหนะ
  String? _riderFileName;
  String? _vehicleFileName;

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

                        // รูปโปรไฟล์ไรเดอร์
                        _uploadRow(
                          label: _riderFileName ?? 'อัปโหลดรูปโปรไฟล์',
                          onPick: () async {
                            final XFile? img = await _openImagePopup(context);
                            if (img != null) {
                              setState(() {
                                _riderImg = img;
                                _riderFileName =
                                    img.name; // ⬅️ ใช้ชื่อไฟล์ที่เลือก
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 8),

                        // รูปยานพาหนะ
                        _uploadRow(
                          label: _vehicleFileName ?? 'อัปโหลดรูปยานพาหนะ',
                          onPick: () async {
                            final XFile? img = await _openImagePopup(context);
                            if (img != null) {
                              setState(() {
                                _vehicleImg = img;
                                _vehicleFileName =
                                    img.name; // ⬅️ ใช้ชื่อไฟล์ที่เลือก
                              });
                            }
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

  Widget _uploadRow({
    required String label,
    required Future<void> Function() onPick,
  }) {
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
              child: Text(label, overflow: TextOverflow.ellipsis),
            ),
          ),
        ),
        const SizedBox(width: 10),
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

  Future<String> _uploadToSupabase({
    required String riderId,
    required XFile file,
    required String filename, // 'profile.jpg' หรือ 'vehicle.jpg'
  }) async {
    final path = 'riders/$riderId/$filename';
    final bytes = await file.readAsBytes();

    await supa.storage
        .from('riders')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

    // ถ้า bucket เป็น public read:
    return supa.storage.from('riders').getPublicUrl(path);

    // ถ้า bucket เป็น private ใช้แบบนี้แทน:
    // final signed = await supa.storage.from('riders').createSignedUrl(path, 3600);
    // return signed;
  }

  Future<void> addData() async {
    // validate ฟิลด์ข้อความ
    if (_username.text.isEmpty ||
        _phone.text.isEmpty ||
        _password.text.isEmpty ||
        _confirm.text.isEmpty ||
        _plate.text.isEmpty) {
      return _show('กรอกข้อมูลไม่ครบ', 'กรุณากรอกข้อมูลทุกช่องให้ครบถ้วน');
    }
    if (_password.text != _confirm.text) {
      return _show('รหัสผ่านไม่ตรงกัน', 'กรุณากรอกรหัสผ่านให้ตรงกัน');
    }
    // ต้องมีรูปทั้งสอง
    if (_riderImg == null || _vehicleImg == null) {
      return _show('ต้องอัปโหลดรูป', 'กรุณาเลือกรูปโปรไฟล์และรูปยานพาหนะ');
    }

    try {
      // ❗ ถ้าทำจริงแนะนำใช้ doc().id ไม่ใช้ count()+1
      final collection = FirebaseFirestore.instance.collection('riders');
      final snapshot = await collection.count().get();
      final riderId = (snapshot.count! + 1).toString();

      final riderUrl = await _uploadToSupabase(
        riderId: riderId,
        file: _riderImg!,
        filename: 'profile.jpg',
      );
      final vehicleUrl = await _uploadToSupabase(
        riderId: riderId,
        file: _vehicleImg!,
        filename: 'vehicle.jpg',
      );

      final data = {
        'name': _username.text.trim(),
        'phone': _phone.text.trim(),
        'password': _password.text.trim(), // โปรดเปลี่ยนเป็น hash ใน production
        'plate_no': _plate.text.trim(),
        'lat': null,
        'lng': null,
        'vehicle_image': vehicleUrl, // ✅ เก็บ URL
        'rider_image': riderUrl, // ✅ เก็บ URL
      };

      await db.collection('riders').doc(riderId).set(data);

      await _show('สำเร็จ', 'เพิ่มข้อมูล Rider เรียบร้อยแล้ว');
      if (mounted) Get.to(() => const LoginPage());
    } catch (e, st) {
      log('add rider error: $e\n$st');
      _show('ผิดพลาด', e.toString());
    }
  }

  Future<void> _show(String t, String m) => showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(t),
      content: Text(m),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ตกลง'),
        ),
      ],
    ),
  );

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

                    // แถว: อัปโหลดรูปโปรไฟล์ | เลือกรูป
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
}
