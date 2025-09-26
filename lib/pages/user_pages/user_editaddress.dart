import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditAddressPage extends StatefulWidget {
  final String initialAddress;
  const EditAddressPage({super.key, required this.initialAddress});

  @override
  State<EditAddressPage> createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  static const bg = Color(0xFFD2C2F1);
  static const cardBg = Color(0xFFF4EBFF);
  static const borderCol = Color(0x55000000);
  static const linkBlue = Color(0xFF2D72FF);

  late final TextEditingController _addrCtrl;

  @override
  void initState() {
    super.initState();
    _addrCtrl = TextEditingController(text: widget.initialAddress);
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
          'แก้ไขที่อยู่',
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
                  border: Border.all(color: borderCol),
                  borderRadius: BorderRadius.circular(12),
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

                    // กล่องที่อยู่ (หลายบรรทัด)
                    TextField(
                      controller: _addrCtrl,
                      minLines: 3,
                      maxLines: 5,
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: 'กรอกที่อยู่ให้ครบถ้วน',
                      ),
                    ),

                    const SizedBox(height: 12),

                    // แผนที่ placeholder ตามภาพ
                    Container(
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: borderCol),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.map_outlined, color: Colors.black54),
                          SizedBox(width: 8),
                          Text('แผนที่ (ตัวอย่าง)'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ปุ่มยกเลิก / ยืนยัน
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Get.back(), // ไม่ส่งค่า
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
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
                             onPressed: () => Get.back(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('ยืนยัน'),
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

      // (ไม่จำเป็นต้องมี BottomNav ในหน้าฟอร์มนี้ แต่ถ้าอยากใส่ตามภาพหลักก็เพิ่มได้)
    );
  }
}
