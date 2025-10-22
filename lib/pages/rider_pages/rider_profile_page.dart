import 'package:flutter/material.dart';
import 'package:mobile_delivery/pages/rider_pages/rider_edit_vehicle.dart';
import 'package:mobile_delivery/pages/rider_pages/rider_home.dart';

class RiderProfilePage extends StatefulWidget {
  const RiderProfilePage({super.key});

  @override
  State<RiderProfilePage> createState() => _RiderProfilePageState();
}

class _RiderProfilePageState extends State<RiderProfilePage> {
  // โทนสีโปรเจ็กต์
  static const bg = Color(0xFFD2C2F1);
  static const cardBg = Color(0xFFF4EBFF);
  static const borderCol = Color(0x55000000);
  static const linkBlue = Color(0xFF2D72FF);

  int _navIndex = 1; // แท็บโปรไฟล์

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        automaticallyImplyLeading: false, // <-- ซ่อนปุ่มย้อนกลับ
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'โปรไฟล์',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // อวตารไรเดอร์
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundColor: Colors.white,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: Image.network(
                          'https://i.pravatar.cc/160?img=15',
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.person, size: 64),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              const Text(
                'ข้อมูลไรเดอร์',
                style: TextStyle(
                  color: linkBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),

              // การ์ดข้อมูลพื้นฐาน
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderCol),
                ),
                child: const _InfoRows(
                  rows: [
                    ['ชื่อ', 'นายนนท์'],
                    ['เบอร์โทร', '062-395-6423'],
                    ['ป้ายทะเบียน', '9 รถ 2019 กรุงเทพมหานคร'],
                  ],
                ),
              ),

              const SizedBox(height: 16),

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
                      // ตัวอย่างรูปมอเตอร์ไซค์
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

              const SizedBox(height: 18),

              // ปุ่มการกระทำ
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('ออกจากระบบ (ตัวอย่าง UI)'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('ออกจากระบบ'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RiderEditVehiclePage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: linkBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('แก้ไขยานพาหนะ'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // แถบนำทางล่าง (สไตล์ให้เหมือนภาพตัวอย่าง)
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
          // ถ้า i == 1 คือโปรไฟล์เอง ไม่ต้องทำอะไร
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

/* ----------------- widgets ย่อย ----------------- */

class _InfoRows extends StatelessWidget {
  const _InfoRows({required this.rows});
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: rows
          .map(
            (r) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 88,
                    child: Text(
                      '${r[0]} :',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(child: Text(r[1])),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
