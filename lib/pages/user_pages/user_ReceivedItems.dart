import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_delivery/pages/user_pages/user_home.dart';
import 'package:mobile_delivery/pages/user_pages/user_profile.dart';
import 'package:mobile_delivery/pages/user_pages/user_receivedstatus.dart';
import 'package:mobile_delivery/pages/user_pages/user_sentItems.dart';

class ReceivedItemsPage extends StatefulWidget {
  const ReceivedItemsPage({super.key});

  @override
  State<ReceivedItemsPage> createState() => _ReceivedItemsPageState();
}

class _ReceivedItemsPageState extends State<ReceivedItemsPage> {
  static const bg = Color(0xFFD2C2F1);
  static const cardBg = Color(0xFFF4EBFF);

  int _navIndex = 2; // แท็บ "สินค้าที่ได้รับ"

  final _items = const <_ReceivedItem>[
    _ReceivedItem(
      name: 'Nintendo Switch',
      phone: '088-888-8888',
      status: '[1] รอไปรับสินค้า',
      imageUrl: 'https://picsum.photos/seed/switch1/200',
    ),
    _ReceivedItem(
      name: 'Nintendo Switch',
      phone: '088-888-8888',
      status: '[1] รอไปรับสินค้า',
      imageUrl: 'https://picsum.photos/seed/switch2/200',
    ),
    _ReceivedItem(
      name: 'Nintendo Switch',
      phone: '088-888-8888',
      status: '[1] รอไปรับสินค้า',
      imageUrl: 'https://picsum.photos/seed/switch3/200',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        automaticallyImplyLeading: false, // ซ่อนปุ่มย้อนกลับ
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'รายการสินค้าที่ได้รับ',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      // ใช้ Stack เพื่อวางปุ่ม "แผนที่รวม" มุมขวาล่าง
      body: Stack(
        children: [
          ListView.separated(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              16 + kBottomNavigationBarHeight,
            ),
            itemBuilder: (_, i) => _ReceivedCard(
              item: _items[i],
              onTap: () => Get.to(() => const ReceivedStatusPage()),
            ),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: _items.length,
          ),

          // ปุ่ม "แผนที่รวม" (ยังไม่ต้องมีความสามารถ)
          Positioned(
            right: 16,
            bottom: 12 + kBottomNavigationBarHeight,
            child: SafeArea(
              child: SizedBox(
                height: 32,
                child: ElevatedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.map_outlined, size: 16),
                  label: const Text(
                    'แผนที่รวม',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.black87,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

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
          if (i == 1) {
            // ไปหน้า "หน้าหลัก" และแทนหน้าปัจจุบัน
            Get.off(() => const SentItemsPage());
            return;
          }
          if (i == 2) {
            // ไปหน้า "หน้าหลัก" และแทนหน้าปัจจุบัน
            Get.off(() => const ReceivedItemsPage());
            return;
          }
          if (i == 3) {
            // ไปหน้า "หน้าหลัก" และแทนหน้าปัจจุบัน
            Get.off(() => const UserProfilePage());
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
}

class _ReceivedItem {
  final String name;
  final String phone;
  final String status;
  final String imageUrl;
  const _ReceivedItem({
    required this.name,
    required this.phone,
    required this.status,
    required this.imageUrl,
  });
}

class _ReceivedCard extends StatelessWidget {
  const _ReceivedCard({required this.item, this.onTap});
  final _ReceivedItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const borderCol = Color(0x55000000);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF4EBFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderCol),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // รูปสินค้า
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                item.imageUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 64,
                  height: 64,
                  color: Colors.white,
                  child: const Icon(Icons.inventory_2, size: 32),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // รายละเอียด
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'เบอร์ผู้ส่ง : ${item.phone}',
                    style: const TextStyle(fontSize: 13.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'สถานะสินค้า : ${item.status}',
                    style: const TextStyle(fontSize: 13.5),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ปุ่มแผนที่ (ยังไม่ทำงาน)
            SizedBox(
              height: 32,
              child: ElevatedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.location_on_outlined, size: 16),
                label: const Text('แผนที่', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.black87,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
