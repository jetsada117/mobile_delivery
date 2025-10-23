import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; //ขอ A นะครับ จุ๊บม๊วฟ
import 'package:get/get.dart'; //ขอ A นะครับ จุ๊บม๊วฟ
import 'package:latlong2/latlong.dart'; //ขอ A นะครับ จุ๊บม๊วฟ
import 'package:mobile_delivery/models/send_item_view.dart'; //ขอ A นะครับ จุ๊บม๊วฟ
import 'package:mobile_delivery/pages/user_pages/user_receiveditems.dart'; //ขอ A นะครับ จุ๊บม๊วฟ
import 'package:mobile_delivery/pages/user_pages/user_combined_map.dart'; //ขอ A นะครับ จุ๊บม๊วฟ
import 'package:mobile_delivery/pages/user_pages/user_home.dart'; //ขอ A นะครับ จุ๊บม๊วฟ
import 'package:mobile_delivery/pages/user_pages/user_profile.dart'; //ขอ A นะครับ จุ๊บม๊วฟ
import 'package:mobile_delivery/pages/user_pages/user_rider_map.dart'; //ขอ A นะครับ จุ๊บม๊วฟ
import 'package:mobile_delivery/pages/user_pages/user_statuschat.dart'; //ขอ A นะครับ จุ๊บม๊วฟ
import 'package:mobile_delivery/providers/auth_provider.dart'; //ขอ A นะครับ จุ๊บม๊วฟ
import 'package:mobile_delivery/repositories/send_item_view.dart'; //ขอ A นะครับ จุ๊บม๊วฟ
import 'package:mobile_delivery/utils/functions.dart'; //ขอ A นะครับ จุ๊บม๊วฟ
import 'package:provider/provider.dart'; //ขอ A นะครับ จุ๊บม๊วฟ

class SentItemsPage extends StatefulWidget {
  const SentItemsPage({super.key});

  @override
  State<SentItemsPage> createState() => _SentItemsPageState();
}

class _SentItemsPageState extends State<SentItemsPage> {
  static const bg = Color(0xFFD2C2F1);
  static const cardBg = Color(0xFFF4EBFF);

  int _navIndex = 1;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final senderId = auth.currentUser?.uid ?? '';

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
          StreamBuilder<List<SentItemView>>(
            stream: sentItemViewsStream(senderId),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(
                  child: Text('โหลดข้อมูลไม่สำเร็จ: ${snap.error}'),
                );
              }
              final items = snap.data ?? [];
              if (items.isEmpty) {
                return const Center(child: Text('ยังไม่มีรายการที่กำลังส่ง'));
              }

              return ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  16 + kBottomNavigationBarHeight,
                ),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final v = items[i];
                  final name = v.product?.name ?? '(ไม่มีชื่อสินค้า)';
                  final phone = v.receiver?.phone ?? '-';
                  final imageUrl = v.product?.imageUrl ?? '';
                  final status = statusLabel(v.order.currentStatus);

                  return _SentCard(
                    item: _SentItem(
                      name: name,
                      phone: phone,
                      status: status,
                      imageUrl: imageUrl,
                    ),
                    onTap: () {
                      Get.to(
                        () => StatusChatPage(
                          orderId: v.order.orderId,
                          title: "สถานะสินค้าที่ส่ง",
                        ),
                      );
                    },
                    onMapTap: () async {
                      final sender = await _latLngFromPath(v.order.sendAt);
                      final receiver = await _latLngFromPath(v.order.receiveAt);

                      if (sender == null || receiver == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('ไม่พบพิกัดที่อยู่ผู้ส่งหรือผู้รับ'),
                          ),
                        );
                        return;
                      }

                      // ถ้ามีข้อมูลไรเดอร์ครบ (lat,lng) ค่อยสร้าง LatLng ไม่งั้นให้เป็น null
                      LatLng? riderLatLng;
                      if (v.rider != null &&
                          v.rider!.lat != null &&
                          v.rider!.lng != null) {
                        riderLatLng = LatLng(v.rider!.lat!, v.rider!.lng!);
                      }

                      Get.to(
                        () => RiderMapPage(
                          riderLatLng: riderLatLng, // <-- อาจเป็น null
                          senderLatLng: sender,
                          receiverLatLng: receiver,
                          riderName: v.rider?.name,
                          phone: v.rider?.phone,
                          plate: v.rider?.plateNo,
                          avatarUrl: v.rider?.riderImage,
                          statusText: status,
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),

      floatingActionButton: SafeArea(
        minimum: const EdgeInsets.only(right: 8, bottom: 8),
        child: SizedBox(
          height: 36,
          child: ElevatedButton.icon(
            onPressed: () {
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
            label: const Text('แผนที่รวม', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        backgroundColor: cardBg,
        onTap: (i) {
          if (i == 0) {
            Get.off(() => const UserHomePage());
            return;
          }
          if (i == 1) {
            Get.off(() => const SentItemsPage());
            return;
          }
          if (i == 2) {
            Get.off(() => const ReceivedItemsPage());
            return;
          }
          if (i == 3) {
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

  Future<LatLng?> _latLngFromPath(String? path) async {
    if (path == null || path.isEmpty) return null;
    final snap = await FirebaseFirestore.instance.doc(path).get();
    if (!snap.exists) return null;
    final data = snap.data() as Map<String, dynamic>;
    final lat = (data['lat'] as num?)?.toDouble();
    final lng = (data['lng'] as num?)?.toDouble();
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
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
  const _SentCard({
    required this.item,
    required this.onTap,
    required this.onMapTap,
  });
  final _SentItem item;
  final VoidCallback onTap;
  final VoidCallback onMapTap;

  @override
  Widget build(BuildContext context) {
    const borderCol = Color(0x55000000);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
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
                  onPressed: onMapTap,
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
