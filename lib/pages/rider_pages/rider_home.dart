import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_delivery/pages/rider_pages/rider_profile_page.dart';
import 'package:provider/provider.dart';
import 'package:mobile_delivery/models/product_data.dart';
import 'package:mobile_delivery/models/rider_data.dart';
import 'package:mobile_delivery/providers/auth_provider.dart';

class RiderHomePage extends StatefulWidget {
  const RiderHomePage({super.key});

  @override
  State<RiderHomePage> createState() => _RiderHomePageState();
}

class _RiderHomePageState extends State<RiderHomePage> {
  final _search = TextEditingController();
  int _navIndex = 0;

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
    final RiderData? rider = auth.currentRider;

    if (rider == null) {
      return const Scaffold(
        backgroundColor: bg,
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    final q = _search.text.trim().toLowerCase();

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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: (rider.riderImage.isEmpty)
                          ? const Icon(Icons.person)
                          : Image.network(
                              rider.riderImage,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.person),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'สวัสดี, ${rider.name}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (rider.plateNo.isNotEmpty)
                          Text(
                            'ทะเบียน: ${rider.plateNo}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'ค้นหาออเดอร์...',
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
                'รายการออเดอร์ทั้งหมด :',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),

              StreamBuilder<List<Product>>(
                stream: _availableOrdersStream(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return const Text('ไม่สามารถโหลดรายการสินค้าได้');
                  }

                  final all = snap.data ?? [];
                  final filtered = (q.isEmpty)
                      ? all
                      : all
                            .where(
                              (p) =>
                                  p.name.toLowerCase().contains(q) ||
                                  p.productId.toString().contains(q),
                            )
                            .toList();

                  if (filtered.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 32),
                      child: Center(
                        child: Text('ไม่มีออเดอร์ที่รอรับในขณะนี้'),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _ProductCardFromModel(
                      product: filtered[i],
                      riderId: rider.id, // << ส่ง riderId ลงไป
                      onAccept: (p) =>
                          _acceptOrder(p, rider.id), // << callback กดรับงาน
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        backgroundColor: cardBg,
        onTap: (i) {
          if (i == _navIndex) return;
          setState(() => _navIndex = i);

          if (i == 0) {
            return;
          }

          if (i == 1) {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const RiderProfilePage()));
          }
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

  Stream<List<Product>> _availableOrdersStream() async* {
    final db = FirebaseFirestore.instance;

    await for (final orderSnap
        in db
            .collection('orders')
            .where('current_status', isEqualTo: 1)
            .where('is_active', isEqualTo: false)
            .snapshots()) {
      final orderIds = orderSnap.docs
          .map((d) => (d.data()['order_id'] as num?)?.toInt())
          .whereType<int>()
          .toList();

      if (orderIds.isEmpty) {
        yield const <Product>[];
        continue;
      }

      final List<Product> all = [];
      final productsCol = db.collection('products');

      for (var i = 0; i < orderIds.length; i += 10) {
        final chunk = orderIds.sublist(
          i,
          (i + 10 > orderIds.length) ? orderIds.length : i + 10,
        );

        final prodSnap = await productsCol
            .where('order_id', whereIn: chunk)
            .get();
        all.addAll(prodSnap.docs.map(Product.fromDoc));
      }

      all.sort((a, b) => b.productId.compareTo(a.productId));
      yield all;
    }
  }

  Future<void> _acceptOrder(Product product, String riderId) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการรับงาน'),
        content: Text('คุณต้องการรับงาน “${product.name}” ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ยืนยัน'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      final docId = product.orderId.toString();
      await FirebaseFirestore.instance.collection('orders').doc(docId).update({
        'rider_id': riderId,
        'current_status': 2,
        'is_active': true,
        'updated_at': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('รับงานสำเร็จ: ${product.name}')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('รับงานไม่สำเร็จ: $e')));
    }
  }
}

class _ProductCardFromModel extends StatelessWidget {
  final Product product;
  final String riderId;
  final Future<void> Function(Product) onAccept;

  const _ProductCardFromModel({
    required this.product,
    required this.riderId,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    const borderCol = Color(0x55000000);

    return InkWell(
      onTap: () async {
        // กดทั้งใบ = รับงาน
        await onAccept(product);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF4EBFF),
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
                errorBuilder: (_, __, ___) => Container(
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
                product.name.isEmpty ? '(ไม่มีชื่อสินค้า)' : product.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            // ไอคอนสื่อว่า "กดเพื่อรับงาน"
            const Icon(Icons.check_circle_outline),
          ],
        ),
      ),
    );
  }
}
