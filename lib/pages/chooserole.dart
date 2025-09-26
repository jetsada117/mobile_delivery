import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_delivery/pages/rider_pages/rider_register.dart';
import 'package:mobile_delivery/pages/user_pages/user_register.dart';

class ChooseRole extends StatefulWidget {
  const ChooseRole({super.key});

  @override
  State<ChooseRole> createState() => _ChooseRoleState();
}

class _ChooseRoleState extends State<ChooseRole> {
  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFD2C2F1);
    const cardBg = Color(0xFFF4EBFF);
    const pill = Color(0xFFC9A9F5);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              const Text(
                'สมัครสมาชิก',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              // โลโก้วงกลม
              Center(
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFBFADE6),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/system/logo.jpg', // เปลี่ยนพาธตามโปรเจกต์คุณ
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // การ์ดเลือกประเภท
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Card(
                    color: cardBg,
                    elevation: 1.2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: Colors.black.withOpacity(0.35)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'คุณจะสมัครสมาชิกประเภทใด',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // ปุ่ม User
                          SizedBox(
                            width: 240,
                            height: 42,
                            child: ElevatedButton(
                              onPressed: () {
                                Get.to(() => const UserRegister());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: pill,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text('ผู้ใช้'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // ปุ่ม Rider
                          SizedBox(
                            width: 240,
                            height: 42,
                            child: ElevatedButton(
                              onPressed: () {
                                Get.to(() => const RiderRegister());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: pill,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text('ไรเดอร์'),
                            ),
                          ),
                          const SizedBox(height: 18),
                          // ปุ่มยกเลิก สีดำ ทรง pill
                          Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                              height: 36,
                              width: 96,
                              child: ElevatedButton(
                                onPressed: () => Get.back(), // ✅ ใช้ GetX
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text('ยกเลิก'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
