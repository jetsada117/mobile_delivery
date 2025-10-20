import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_delivery/pages/user_pages/user_ReceivedItems.dart';
import 'package:mobile_delivery/pages/user_pages/user_combined_map.dart';
import 'package:mobile_delivery/pages/user_pages/user_home.dart';
import 'package:mobile_delivery/pages/user_pages/user_profile.dart';
import 'package:mobile_delivery/pages/user_pages/user_rider_map.dart';
import 'package:mobile_delivery/pages/user_pages/user_shipmentchat.dart';

class SentItemsPage extends StatefulWidget {
  const SentItemsPage({super.key});

  @override
  State<SentItemsPage> createState() => _SentItemsPageState();
}

class _SentItemsPageState extends State<SentItemsPage> {
  static const bg = Color(0xFFD2C2F1);
  static const cardBg = Color(0xFFF4EBFF);

  int _navIndex = 1; // แท็บ "สินค้าที่ส่ง"

  final _items = <_SentItem>[
    _SentItem(
      name: 'ปลากระป๋อง',
      phone: '085-858-8588',

      status: 'กำลังจัดส่งสินค้า',
      imageUrl: 'https://picsum.photos/seed/can/200',
    ),
    _SentItem(
      name: 'มาม่า',
      phone: '088-888-8888',

      status: 'เตรียมจัดส่ง',
      imageUrl: 'https://picsum.photos/seed/noodle/200',
    ),
    _SentItem(
      name: 'ไข่ไก่',
      phone: '083-333-3333',

      status: '[1] กำลังจัดส่งสินค้า',
      imageUrl: 'https://picsum.photos/seed/egg/200',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'รายการสินค้าที่ส่ง',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      body: Stack(
        children: [
          ListView.separated(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              16 + kBottomNavigationBarHeight,
            ),
            itemBuilder: (_, i) => _SentCard(item: _items[i]),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: _items.length,
          ),

          Positioned(
            right: 16,
            bottom: 12 + kBottomNavigationBarHeight,
            child: SafeArea(
              child: SizedBox(
                height: 32,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // ตัวอย่างพิกัดหลายจุด (แก้เป็นของจริงได้)
                    final points = <LatLng>[
                      const LatLng(16.2448, 103.2520),
                      const LatLng(16.2380, 103.2425),
                      const LatLng(16.2325, 103.2580),
                    ];

                    Get.to(
                      () => CombinedMapPage(
                        points: points,
                        riderName: 'นายสมชาย เดลิเวอรี่',
                        statusText: '[3]',
                        phone: '012-345-6789',
                        plate: '8กพ 877',
                        avatarUrl: 'https://i.pravatar.cc/100?img=15',
                      ),
                    );
                  },
                  icon: const Icon(Icons.map_outlined, size: 16),
                  label: const Text(
                    'แผนที่รวม',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
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

class _SentItem {
  final String name;
  final String phone;
  final String status;
  final String imageUrl;

  const _SentItem({
    required this.name,
    required this.phone,
    required this.status,
    required this.imageUrl,
  });
}

class _SentCard extends StatelessWidget {
  const _SentCard({required this.item});
  final _SentItem item;

  @override
  Widget build(BuildContext context) {
    const borderCol = Color(0x55000000);

    return Material(
      // <- ให้มีเอฟเฟกต์ ripple
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // ไปหน้าแชต (จะส่งชื่อสินค้าตามไปด้วยก็ได้)
          Get.to(() => const ShipmentChatPage());
          // หรือถ้าหน้าแชตรับพารามิเตอร์:
          // Get.to(() => ShipmentChatPage(title: item.name));
        },
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
                      'เบอร์ผู้รับ : ${item.phone}',
                      style: const TextStyle(fontSize: 13.5),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'สถานะ : ${item.status}',
                      style: const TextStyle(fontSize: 13.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 32,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // ค่า lat/lng ตัวอย่าง: มมส (ปรับแก้ได้ตามจริง)
                    Get.to(
                      () => RiderMapPage(
                        latLng: const LatLng(16.2458, 103.2500),
                        riderName: 'นายสมชาย เดลิเวอรี่',
                        statusText: item.status, // ใช้สถานะจากการ์ด
                        phone: '012-345-6789',
                        plate: '8กพ 877',
                        avatarUrl: item
                            .imageUrl, // ใช้รูปสินค้าหรือเปลี่ยนเป็นรูปไรเดอร์จริง
                      ),
                    );
                  },
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
      ),
    );
  }
}
