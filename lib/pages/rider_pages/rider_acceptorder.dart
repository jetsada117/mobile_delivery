import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_delivery/models/order_record.dart';
import 'package:mobile_delivery/models/product_data.dart';
import 'package:mobile_delivery/models/send_item_view.dart';
import 'package:mobile_delivery/models/user_address.dart';
import 'package:mobile_delivery/models/user_data.dart';
import 'package:mobile_delivery/pages/rider_pages/rider_home.dart';

class RiderAcceptOrderPage extends StatefulWidget {
  const RiderAcceptOrderPage({super.key, required this.orderId});
  final String orderId;

  @override
  State<RiderAcceptOrderPage> createState() => _RiderAcceptOrderPageState();
}

class _RiderAcceptOrderPageState extends State<RiderAcceptOrderPage> {
  static const bg = Color(0xFFD2C2F1);
  static const cardBg = Color(0xFFF4EBFF);
  static const borderCol = Color(0x55000000);

  final _db = FirebaseFirestore.instance;

  LatLng? _riderPos;
  Future<void>? _locFuture;

  @override
  void initState() {
    super.initState();
    _locFuture = _ensureRiderLocation();
  }

  Future<void> _ensureRiderLocation() async {
    LocationPermission p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      p = await Geolocator.requestPermission();
    }
    if (p == LocationPermission.deniedForever) return;
    final pos = await Geolocator.getCurrentPosition();
    _riderPos = LatLng(pos.latitude, pos.longitude);
  }

  Future<SentItemView> _loadView(String orderId) async {
    final oDoc = await _db.collection('orders').doc(orderId).get();
    if (!oDoc.exists) throw 'ไม่พบออเดอร์ $orderId';
    final order = OrderRecord.fromDoc(oDoc);

    Product? product;
    final pSnap = await _db
        .collection('products')
        .where('order_id', isEqualTo: order.orderId)
        .limit(1)
        .get();
    if (pSnap.docs.isNotEmpty) {
      product = Product.fromDoc(pSnap.docs.first);
    }

    UserData? sender;
    UserData? receiver;
    if (order.sendId.isNotEmpty) {
      final d = await _db.collection('users').doc(order.sendId).get();
      if (d.exists) sender = UserData.fromMap(d.id, d.data() ?? {});
    }
    if (order.receiveId!.isNotEmpty) {
      final d = await _db.collection('users').doc(order.receiveId).get();
      if (d.exists) receiver = UserData.fromMap(d.id, d.data() ?? {});
    }

    Future<UserAddress?> addr(String? path) async {
      if (path == null || path.trim().isEmpty) return null;
      final d = await _db.doc(path).get();
      return d.exists ? UserAddress.fromDoc(d) : null;
    }

    final sendAddr = await addr(order.sendAt);
    final receiveAddr = await addr(order.receiveAt);

    final view = SentItemView(
      order: order,
      product: product,
      receiver: receiver,
      sendAddress: sendAddr,
      receiveAddress: receiveAddr,
      rider: null,
    )..extra = sender;

    return view;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'รายละเอียดออเดอร์',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: FutureBuilder(
        future: Future.wait([
          _locFuture ?? Future.value(),
          _loadView(widget.orderId),
        ]),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('โหลดข้อมูลไม่สำเร็จ: ${snap.error}'));
          }

          final SentItemView view = (snap.data as List).last as SentItemView;
          final product = view.product;
          final sender = view.extra is UserData ? view.extra as UserData : null;
          final receiver = view.receiver;

          final sendLat = view.sendAddress?.lat;
          final sendLng = view.sendAddress?.lng;
          final recvLat = view.receiveAddress?.lat;
          final recvLng = view.receiveAddress?.lng;

          final LatLng? sendPos = (sendLat != null && sendLng != null)
              ? LatLng(sendLat, sendLng)
              : null;
          final LatLng? recvPos = (recvLat != null && recvLng != null)
              ? LatLng(recvLat, recvLng)
              : null;

          final dist = const Distance();
          double? kmRiderToSend;
          double? kmRiderToRecv;

          if (_riderPos != null && sendPos != null) {
            kmRiderToSend = dist.as(LengthUnit.Meter, _riderPos!, sendPos);
          }
          if (_riderPos != null && recvPos != null) {
            kmRiderToRecv = dist.as(LengthUnit.Meter, _riderPos!, recvPos);
          }

          final initialCenter =
              sendPos ?? recvPos ?? _riderPos ?? const LatLng(16.2458, 103.25);

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: (product?.imageUrl.isNotEmpty ?? false)
                          ? Image.network(
                              product!.imageUrl,
                              width: 140,
                              height: 110,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _imgFallback(),
                            )
                          : _imgFallback(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'ชื่อสินค้า: ${product?.name.isNotEmpty == true ? product!.name : "(ไม่ระบุ)"}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  _PersonCard(
                    title: 'ข้อมูลผู้ส่ง',
                    name: sender?.name ?? '-',
                    phone: sender?.phone ?? '-',
                    imageUrl: sender?.imageUrl ?? '',
                  ),
                  const SizedBox(height: 10),
                  _PersonCard(
                    title: 'ข้อมูลผู้รับ',
                    name: receiver?.name ?? '-',
                    phone: receiver?.phone ?? '-',
                    imageUrl: receiver?.imageUrl ?? '',
                  ),
                  const SizedBox(height: 12),

                  Container(
                    height: 260,
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderCol),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: initialCenter,
                        initialZoom: 14.2,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.thunderforest.com/atlas/{z}/{x}/{y}.png?apikey=6949d257c8de4157a028c7a44b05af3d',
                          userAgentPackageName: 'com.example.mobile_delivery',
                        ),
                        MarkerLayer(
                          markers: [
                            if (sendPos != null)
                              Marker(
                                point: sendPos,
                                width: 36,
                                height: 36,
                                child: const Icon(
                                  Icons.store,
                                  color: Colors.orange,
                                  size: 32,
                                ),
                              ),
                            if (recvPos != null)
                              Marker(
                                point: recvPos,
                                width: 36,
                                height: 36,
                                child: const Icon(
                                  Icons.home,
                                  color: Colors.green,
                                  size: 32,
                                ),
                              ),
                            if (_riderPos != null)
                              Marker(
                                point: _riderPos!,
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  Icons.delivery_dining,
                                  size: 36,
                                  color: Colors.black87,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderCol),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ระยะทางจากฉัน ➜ จุดรับสินค้า : ${kmRiderToSend != null ? kmRiderToSend.toStringAsFixed(2) : "-"} เมตร',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'ระยะทางจากฉัน ➜ จุดส่งสินค้า : ${kmRiderToRecv != null ? kmRiderToRecv.toStringAsFixed(2) : "-"} เมตร',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RiderHomePage(),
                                ),
                                (route) => false,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('ยกเลิก'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'รับออเดอร์: ${product?.name ?? "#${view.order.orderId}"}',
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('รับออเดอร์'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _imgFallback() => Container(
    width: 140,
    height: 110,
    color: Colors.white,
    alignment: Alignment.center,
    child: const Icon(Icons.inventory_2, size: 40),
  );
}

class _PersonCard extends StatelessWidget {
  const _PersonCard({
    required this.title,
    required this.name,
    required this.phone,
    this.imageUrl,
  });

  final String title;
  final String name;
  final String phone;
  final String? imageUrl;

  static const cardBg = Color(0xFFF4EBFF);
  static const borderCol = Color(0x55000000);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol),
      ),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white,
            backgroundImage: (imageUrl != null && imageUrl!.isNotEmpty)
                ? NetworkImage(imageUrl!)
                : null,
            child: (imageUrl == null || imageUrl!.isEmpty)
                ? const Icon(Icons.person, color: Colors.black45)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text('ชื่อ : $name'),
                Text('เบอร์โทร : $phone'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
