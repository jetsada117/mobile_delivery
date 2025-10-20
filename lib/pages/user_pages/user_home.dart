import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:mobile_delivery/pages/user_pages/user_ReceivedItems.dart';
import 'package:mobile_delivery/pages/user_pages/user_createparcel.dart';
import 'package:mobile_delivery/pages/user_pages/user_profile.dart';
import 'package:mobile_delivery/pages/user_pages/user_sentItems.dart';
import 'package:mobile_delivery/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _navIndex = 0;
  final _search = TextEditingController();

  final _items = const [
    _Product(
      name: 'ปลากระป๋อง',
      imageUrl: 'https://picsum.photos/seed/can/200',
    ),
    _Product(name: 'มาม่า', imageUrl: 'https://picsum.photos/seed/noodle/200'),
    _Product(name: 'ไข่ไก่', imageUrl: 'https://picsum.photos/seed/egg/200'),
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFD2C2F1);
    const cardBg = Color(0xFFF4EBFF);
    const borderCol = Color(0x55000000);

    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    final displayName = user?.name;
    final avatarUrl = user?.imageUrl;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: Image.network(
                          avatarUrl!,
                          errorBuilder: (c, e, s) => const Icon(Icons.person),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'สวัสดี, $displayName',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ช่องค้นหา
              TextField(
                controller: _search,
                decoration: InputDecoration(
                  hintText: 'ค้นหา......',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: borderCol),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'รายการสินค้าของคุณ :',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),

              // รายการสินค้า (การ์ด)
              ..._items.map((p) => _ProductCard(product: p)).toList(),
              const SizedBox(height: 8),

              // ปุ่มสร้างสินค้า (ชิดขวา)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const CreateParcelPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('สร้างสินค้า'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation
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

class _Product {
  final String name;
  final String imageUrl;
  const _Product({required this.name, required this.imageUrl});
}

class _ProductCard extends StatelessWidget {
  final _Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    const borderCol = Color(0x55000000);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4EBFF),
        borderRadius: BorderRadius.circular(12),
        // border: const BorderSide(color: borderCol).toPaint(),
      ),
      child: Container(
        // ใช้ Container ซ้อนเพื่อให้ Border ดูชัด
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderCol),
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                product.imageUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  width: 64,
                  height: 64,
                  color: Colors.white,
                  child: const Icon(Icons.inventory_2, size: 32),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                product.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
