import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_delivery/models/send_item_view.dart';
import 'package:mobile_delivery/pages/user_pages/user_home.dart';
import 'package:mobile_delivery/pages/user_pages/user_profile.dart';
import 'package:mobile_delivery/pages/user_pages/user_rider_map.dart';
import 'package:mobile_delivery/pages/user_pages/user_rider_map_receive.dart';
import 'package:mobile_delivery/pages/user_pages/user_sentItems.dart';
import 'package:mobile_delivery/pages/user_pages/user_statuschat.dart';
import 'package:mobile_delivery/providers/auth_provider.dart';
import 'package:mobile_delivery/repositories/receive_item_view.dart';
import 'package:mobile_delivery/utils/functions.dart';
import 'package:provider/provider.dart';

class ReceivedItemsPage extends StatefulWidget {
  const ReceivedItemsPage({super.key});

  @override
  State<ReceivedItemsPage> createState() => _ReceivedItemsPageState();
}

class _ReceivedItemsPageState extends State<ReceivedItemsPage> {
  static const bg = Color(0xFFD2C2F1);
  static const cardBg = Color(0xFFF4EBFF);

  int _navIndex = 2;

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'รายการสินค้าที่ได้รับ',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      body: Stack(
        children: [
          StreamBuilder<List<SentItemView>>(
            stream: receivedItemViewsStream(uid),
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
                return const Center(child: Text('ยังไม่มีรายการที่ได้รับ'));
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
                  final sender = v.extra;
                  final phone = (sender?.phone ?? '-') as String;
                  final imageUrl = v.product?.imageUrl ?? '';
                  final status = statusLabel(v.order.currentStatus);

                  return _ReceivedCard(
                    item: _ReceivedItem(
                      name: name,
                      phone: phone,
                      status: status,
                      imageUrl: imageUrl,
                    ),
                    onTap: () {
                      Get.to(
                        () => StatusChatPage(
                          orderId: v.order.orderId,
                          title: 'สถานะสินค้าที่ได้รับ',
                        ),
                      );
                    },
                    onMapTap: () async {
                      final senderLatLng = await _latLngFromPath(
                        v.order.sendAt,
                      );
                      final receiverLatLng = await _latLngFromPath(
                        v.order.receiveAt,
                      );

                      if (senderLatLng == null || receiverLatLng == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('ไม่พบพิกัดที่อยู่ผู้ส่งหรือผู้รับ'),
                          ),
                        );
                        return;
                      }

                      if (v.rider != null &&
                          v.rider!.lat != null &&
                          v.rider!.lng != null) {}

                      Get.to(
                        () => RiderMapPage(
                          orderId: v.order.orderId
                              .toString(), // ✅ ส่ง orderId เข้าไป
                          senderLatLng: senderLatLng,
                          receiverLatLng: receiverLatLng,
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
            onPressed: () async {
              final uid = context.read<AuthProvider>().currentUser?.uid;
              if (uid == null || uid.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('กรุณาเข้าสู่ระบบก่อน')),
                );
                return;
              }

              final db = FirebaseFirestore.instance;

              try {
                // ดึงเฉพาะออเดอร์ที่ “เราคือผู้รับ”
                final q = await db
                    .collection('orders')
                    .where('receive_id', isEqualTo: uid)
                    .get();

                if (q.docs.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ยังไม่มีออเดอร์ที่ส่งมาหาคุณ'),
                    ),
                  );
                  return;
                }

                final senders = <SenderPin>[];
                final riders = <RiderPin>[];

                // กันรายการซ้ำ
                final seenSenders = <String>{}; // ใช้ send_id
                final seenRiders = <String>{}; // ใช้ rider_id

                for (final d in q.docs) {
                  final data = d.data();

                  final String group = (data['order_id']?.toString() ?? d.id)
                      .toString();
                  final String? sendId = (data['send_id'] as String?)?.trim();
                  final String? sendAt = _extractDocPath(data['send_at']);
                  final String? riderId = (data['rider_id'] as String?)?.trim();

                  // -------- ผู้ส่ง (ร้าน/ผู้ฝากส่ง) --------
                  if (sendId != null &&
                      sendId.isNotEmpty &&
                      !seenSenders.contains(sendId)) {
                    final pos = await _latLngFromPath(sendAt);
                    if (pos != null) {
                      String senderName = 'ผู้ส่ง';
                      String? note;

                      try {
                        // ชื่อ/รูป/เบอร์อยู่ใน users/{sendId}
                        final userDoc = await db
                            .collection('users')
                            .doc(sendId)
                            .get();
                        if (userDoc.exists) {
                          final m = userDoc.data() as Map<String, dynamic>;
                          senderName = (m['name'] as String?) ?? senderName;
                          // ถ้าอยากโชว์เบอร์ใน panel เป็น note ก็เก็บไว้ได้
                          note = m['phone'] as String?;
                        }
                      } catch (_) {}

                      senders.add(
                        SenderPin(
                          group: group,
                          name: senderName,
                          pos: pos,
                          note: note,
                        ),
                      );
                      seenSenders.add(sendId);
                    }
                  }

                  // -------- ไรเดอร์ (ถ้ามีในออเดอร์) --------
                  if (riderId != null &&
                      riderId.isNotEmpty &&
                      !seenRiders.contains(riderId)) {
                    try {
                      final r = await db
                          .collection('riders')
                          .doc(riderId)
                          .get();
                      if (r.exists) {
                        final m = r.data() as Map<String, dynamic>;
                        final lat = (m['lat'] as num?)?.toDouble();
                        final lng = (m['lng'] as num?)?.toDouble();

                        if (lat != null && lng != null) {
                          riders.add(
                            RiderPin(
                              group: group,
                              riderId: riderId,
                              name: (m['name'] as String?) ?? 'ไรเดอร์',
                              pos: LatLng(lat, lng),
                              phone: m['phone'] as String?,
                              plate: m['plate_no'] as String?,
                              avatarUrl: m['rider_image'] as String?,
                            ),
                          );
                          seenRiders.add(riderId);
                        }
                      }
                    } catch (_) {}
                  }
                }

                if (senders.isEmpty && riders.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ไม่มีจุดผู้ส่ง/ไรเดอร์ให้แสดงบนแผนที่'),
                    ),
                  );
                  return;
                }

                // เปิดหน้าแผนที่รวม "ผู้ส่ง + ไรเดอร์"
                Get.to(
                  () => CombinedSendersLiveMapPage(
                    title: 'แผนที่รวมผู้ส่ง',
                    senders: senders,
                    riders: riders,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('ดึงข้อมูลไม่สำเร็จ: $e')),
                );
              }
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
    try {
      final snap = await FirebaseFirestore.instance.doc(path).get();
      if (!snap.exists) return null;
      final data = snap.data() as Map<String, dynamic>;
      final lat = (data['lat'] as num?)?.toDouble();
      final lng = (data['lng'] as num?)?.toDouble();
      if (lat == null || lng == null) return null;
      return LatLng(lat, lng);
    } catch (_) {
      return null;
    }
  }

  String? _extractDocPath(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is DocumentReference) return value.path;
    return null;
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
  const _ReceivedCard({required this.item, this.onTap, required this.onMapTap});

  final _ReceivedItem item;
  final VoidCallback? onTap;
  final VoidCallback onMapTap;

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
            SizedBox(
              height: 32,
              child: ElevatedButton.icon(
                onPressed: onMapTap, // ← ใช้ callback ที่ส่งมาจากหน้า list
                icon: const Icon(Icons.location_on_outlined, size: 16),
                label: const Text('แผนที่', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
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
