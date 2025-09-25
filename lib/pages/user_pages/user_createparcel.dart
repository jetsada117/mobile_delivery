import 'dart:developer' show log;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_delivery/pages/user_pages/user_home.dart';

class CreateParcelPage extends StatefulWidget {
  const CreateParcelPage({super.key});

  @override
  State<CreateParcelPage> createState() => _CreateParcelPageState();
}

class _CreateParcelPageState extends State<CreateParcelPage> {
  // Controllers
  final _name = TextEditingController();
  final _addr1 = TextEditingController(text: 'บ้านเลขที่ 111');
  final _addr2 = TextEditingController(text: 'บ้านเลขที่ 222');

  // Image
  final _picker = ImagePicker();
  XFile? _image;
  XFile? _selectedImage;

  // Address selection (เลือก 1 อย่าง)
  int? _selectedAddr; // 1 หรือ 2

  int _navIndex = 0;

  @override
  void dispose() {
    _name.dispose();
    _addr1.dispose();
    _addr2.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final x = await _picker.pickImage(source: ImageSource.gallery);
    if (x != null) setState(() => _image = x);
  }

  @override
  Widget build(BuildContext context) {
    // theme like mock
    const bg = Color(0xFFD2C2F1);
    const cardBg = Color(0xFFF4EBFF);
    const borderCol = Color(0x55000000);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text(
          'สร้างสินค้า',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                color: cardBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: borderCol),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // รูปสินค้า + ปุ่มอัปโหลด
                      Column(
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: _image == null
                                ? const Icon(Icons.inventory_2, size: 42)
                                : Image.file(
                                    File(_image!.path),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 28,
                            child: ElevatedButton(
                              onPressed: () async {
                                final XFile? img = await _openImagePopup(
                                  context,
                                );
                                if (img != null) {
                                  setState(() => _selectedImage = img);
                                  log('Picked: ${img.path}');
                                } else {
                                  log('No Image');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black87,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'เพิ่มรูปสินค้า',
                                style: TextStyle(fontSize: 12.5),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // ชื่อสินค้า
                      const Text(
                        'ชื่อสินค้า',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      _input(controller: _name, hint: 'ชื่อสินค้า'),

                      const SizedBox(height: 18),

                      // เลือกที่อยู่ผู้สั่ง (พื้นหลังม่วงอ่อน)
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFC9A9F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderCol),
                        ),
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'เลือกที่อยู่ผู้สั่ง',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 10),

                            // ที่อยู่ 1
                            _addressCard(
                              label: 'ที่อยู่ 1',
                              controller: _addr1,
                              checked: _selectedAddr == 1,
                              onCheck: (v) =>
                                  setState(() => _selectedAddr = v ? 1 : null),
                            ),
                            const SizedBox(height: 10),

                            // ที่อยู่ 2
                            _addressCard(
                              label: 'ที่อยู่ 2',
                              controller: _addr2,
                              checked: _selectedAddr == 2,
                              onCheck: (v) =>
                                  setState(() => _selectedAddr = v ? 2 : null),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ปุ่มบันทึก (ถ้าต้องการ)
                      SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const UserHomePage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('บันทึก'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),

      // bottom nav
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        backgroundColor: cardBg,
        onTap: (i) {
          if (i == 0) {
            // ไปหน้า "หน้าหลัก" และแทนหน้าปัจจุบัน
            Get.off(() => const UserHomePage());
            return;
          }
          setState(() => _navIndex = i);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'หน้าหลัก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping_outlined),
            label: 'สินค้าที่ส่ง',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox_outlined),
            label: 'สินค้าที่ได้รับ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'โปรไฟล์',
          ),
        ],
      ),
    );
  }

  // ----- Widgets -----

  Widget _input({
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _addressCard({
    required String label,
    required TextEditingController controller,
    required bool checked,
    required ValueChanged<bool> onCheck,
  }) {
    const borderCol = Color(0x55000000);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          // Map placeholder
          Container(
            width: 70,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEDED),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.map, size: 28, color: Colors.black54),
          ),
          const SizedBox(width: 10),

          // Address field
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'รายละเอียดที่อยู่',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Checkbox สี่เหลี่ยม
          Checkbox(
            value: checked,
            onChanged: (v) => onCheck(v ?? false),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
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
                            child: const Text('อัปโหลดรูปสินค้า'),
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
