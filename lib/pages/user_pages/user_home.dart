import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_delivery/models/product_data.dart';
import 'package:mobile_delivery/pages/user_pages/user_receiveditems.dart';
import 'package:mobile_delivery/pages/user_pages/user_createparcel.dart';
import 'package:mobile_delivery/pages/user_pages/user_profile.dart';
import 'package:mobile_delivery/pages/user_pages/user_sendparcel.dart';
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

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFD2C2F1);
    const cardBg = Color(0xFFF4EBFF);

    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final uid = user!.uid;

    final displayName = user.name;
    final avatarUrl = user.imageUrl;

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
                          avatarUrl,
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

              const Text(
                'รายการสินค้าของคุณ :',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),

              StreamBuilder<List<Product>>(
                stream: productsStream(senderId: uid),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return const Text('โหลดสินค้าไม่สำเร็จ');
                  }
                  final items = snap.data ?? [];
                  if (items.isEmpty) {
                    return const Text('ยังไม่มีสินค้า');
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) =>
                        _ProductCardFromModel(product: items[i]),
                  );
                },
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const CreateParcelPage()),
          );
        },
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_box_outlined),
        label: const Text('สร้างสินค้า'),
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

  Stream<List<Product>> productsStream({required String senderId}) async* {
    if (senderId.isEmpty) {
      yield const <Product>[];
      return;
    }

    final db = FirebaseFirestore.instance;

    await for (final ordSnap
        in db
            .collection('orders')
            .where('send_id', isEqualTo: senderId)
            .where('current_status', isEqualTo: 0)
            .snapshots()) {
      final orderIds = ordSnap.docs
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
}

class _ProductCardFromModel extends StatelessWidget {
  final Product product;
  const _ProductCardFromModel({required this.product});

  @override
  Widget build(BuildContext context) {
    const borderCol = Color(0x55000000);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Get.to(() => SendParcelPage(product: product));
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF4EBFF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name.isEmpty
                            ? '(ไม่มีชื่อสินค้า)'
                            : product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
