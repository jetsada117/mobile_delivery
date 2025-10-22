import 'package:flutter/material.dart';
import 'package:mobile_delivery/pages/rider_pages/rider_home.dart';
import 'package:mobile_delivery/pages/rider_pages/rider_profile_page.dart';

class RiderEditVehiclePage extends StatefulWidget {
  const RiderEditVehiclePage({super.key});

  @override
  State<RiderEditVehiclePage> createState() => _RiderEditVehiclePageState();
}

class _RiderEditVehiclePageState extends State<RiderEditVehiclePage> {
  static const bg = Color(0xFFD2C2F1);
  static const cardBg = Color(0xFFF4EBFF);
  static const borderCol = Color(0x55000000);
  static const linkBlue = Color(0xFF2D72FF);

  final _plateCtrl = TextEditingController(text: '2 กต 47');

  int _navIndex = 1; // โปรไฟล์

  @override
  void dispose() {
    _plateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('แก้ไขยานพาหนะ',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // รูปยานพาหนะ
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderCol),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      'https://i.imgur.com/7f8b0qS.jpeg',
                      width: 280,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 280,
                        height: 180,
                        color: Colors.white,
                        alignment: Alignment.center,
                        child: const Icon(Icons.motorcycle, size: 40),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // ปุ่มอัปโหลด (เดโม่ UI)
              Center(
                child: SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('อัปโหลดรูปภาพ (ตัวอย่าง UI)')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: linkBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('อัปโหลดรูป'),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Text('ทะเบียนรถ',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: _plateCtrl,
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'กรอกทะเบียนรถ',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('บันทึกสำเร็จ (ตัวอย่าง UI)')),
                          );
                          Navigator.pop(context); // กลับไปหน้าโปรไฟล์
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: linkBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('บันทึก'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('ยกเลิก'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // Bottom nav
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        backgroundColor: cardBg,
        onTap: (i) {
          if (i == 0) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const RiderHomePage()),
            );
          }
              if (i == 1) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const RiderProfilePage()),
            );
          }
          // i == 1 อยู่หน้าโปรไฟล์/แก้ไขอยู่แล้ว ไม่ทำอะไร
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'หน้าหลัก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'โปรไฟล์',
          ),
        ],
      ),
    );
  }
}
