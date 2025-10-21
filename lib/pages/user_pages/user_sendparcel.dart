import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:mobile_delivery/models/product_data.dart';
import 'package:mobile_delivery/models/user_data.dart';
import 'package:mobile_delivery/models/user_address.dart';
import 'package:mobile_delivery/pages/user_pages/user_home.dart';
import 'package:mobile_delivery/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SendParcelPage extends StatefulWidget {
  final Product product;
  const SendParcelPage({super.key, required this.product});

  @override
  State<SendParcelPage> createState() => _SendParcelPageState();
}

class _SendParcelPageState extends State<SendParcelPage> {
  static const bg = Color(0xFFD2C2F1);
  static const cardBg = Color(0xFFF4EBFF);
  static const innerCard = Color(0xFFC9A9F5);
  static const borderCol = Color(0x55000000);
  static const linkBlue = Color(0xFF2D72FF);

  final supa = Supabase.instance.client;

  final _phoneSearch = TextEditingController();
  bool _isSearching = false;
  bool _submitting = false;

  UserData? _recipient;
  List<UserAddress> _addresses = [];
  String? _selectedAddressId;

  @override
  void dispose() {
    _phoneSearch.dispose();
    super.dispose();
  }

  Future<void> _searchRecipientFromFirebase() async {
    final phone = _phoneSearch.text.trim();
    if (phone.isEmpty) {
      Get.snackbar('กรุณากรอกเบอร์โทร', 'โปรดระบุหมายเลขโทรศัพท์ผู้รับ');
      return;
    }

    setState(() => _isSearching = true);

    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        Get.snackbar('ไม่พบผู้ใช้', 'ไม่มีผู้ใช้ที่มีเบอร์นี้ในระบบ');
        setState(() {
          _recipient = null;
          _addresses = [];
          _selectedAddressId = null;
          _isSearching = false;
        });
        return;
      }

      final doc = query.docs.first;
      final user = UserData.fromMap(doc.id, doc.data());
      final addrSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .get();

      final addrList = addrSnap.docs.map(UserAddress.fromDoc).toList();

      setState(() {
        _recipient = user;
        _addresses = addrList;
        _isSearching = false;
      });

      Get.snackbar('สำเร็จ', 'ค้นหาผู้รับเรียบร้อย');
    } catch (e) {
      setState(() => _isSearching = false);
      Get.snackbar('ผิดพลาด', 'เกิดข้อผิดพลาดในการค้นหา: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'ส่งสินค้า',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ค้นหาผู้รับ',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderCol),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _phoneSearch,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'เบอร์โทรศัพท์',
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: _isSearching
                            ? null
                            : _searchRecipientFromFirebase,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: linkBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isSearching
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('ค้นหา'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              if (_recipient != null) _recipientCard(_recipient!, _addresses),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),

      bottomSheet: Container(
        color: bg,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed:
                (_recipient == null ||
                    _selectedAddressId == null ||
                    _submitting)
                ? null
                : _confirmSend,
            style: ElevatedButton.styleFrom(
              backgroundColor: linkBlue,
              disabledBackgroundColor: linkBlue.withOpacity(.4),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 4,
            ),
            child: _submitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'ส่ง',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _recipientCard(UserData user, List<UserAddress> addresses) {
    return Card(
      color: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: borderCol),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: innerCard,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: Image.network(
                      user.imageUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.person, size: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ชื่อผู้รับ : ${user.name}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'เบอร์โทร : ${user.phone}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            if (addresses.isEmpty)
              const Text(
                'ไม่มีที่อยู่ในระบบ',
                style: TextStyle(color: Colors.white),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(addresses.length, (i) {
                  final addr = addresses[i];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ที่อยู่${i + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _addressOptionTileWithMap(addr),
                      const SizedBox(height: 10),
                    ],
                  );
                }),
              ),
          ],
        ),
      ),
    );
  }

  Widget _addressOptionTileWithMap(UserAddress addr) {
    final checked = _selectedAddressId == addr.id;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderCol),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedAddressId = addr.id),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    addr.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  _miniMapForAddress(addr),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Checkbox(
            value: checked,
            onChanged: (_) => setState(() => _selectedAddressId = addr.id),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniMapForAddress(UserAddress addr) {
    if (addr.lat == null || addr.lng == null) {
      return Container(
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFFF4F7F0),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E9DA)),
        ),
        alignment: Alignment.center,
        child: const Text(
          'ไม่มีพิกัด',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
      );
    }

    final center = LatLng(addr.lat!, addr.lng!);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 96,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: 15,
            interactionOptions: const InteractionOptions(
              flags:
                  InteractiveFlag.drag |
                  InteractiveFlag.pinchZoom |
                  InteractiveFlag.flingAnimation |
                  InteractiveFlag.doubleTapZoom,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://tile.thunderforest.com/atlas/{z}/{x}/{y}.png?apikey=6949d257c8de4157a028c7a44b05af3d',
              userAgentPackageName: 'com.example.mobile_delivery',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: center,
                  width: 28,
                  height: 28,
                  child: const Icon(
                    Icons.location_on,
                    size: 24,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _archiveProductImageToDelivery({
    required String imageUrl,
    required int orderId,
    required String uploaderUid,
    int status = 1,
  }) async {
    final res = await http.get(Uri.parse(imageUrl));

    if (res.statusCode != 200) {
      throw Exception('ดาวน์โหลดรูปไม่สำเร็จ (${res.statusCode})');
    }

    final bytes = res.bodyBytes;

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final objectPath = 'delivery_photos/$orderId/$fileName';

    await supa.storage
        .from('delivery')
        .uploadBinary(
          objectPath,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

    final publicUrl = supa.storage.from('delivery').getPublicUrl(objectPath);

    await FirebaseFirestore.instance.collection('delivery_photos').add({
      'image_url': publicUrl,
      'order_id': orderId,
      'status': status,
      'upload_by': uploaderUid,
      'created_at': FieldValue.serverTimestamp(),
    });

    return publicUrl;
  }

  Future<void> _confirmSend() async {
    if (_recipient == null || _selectedAddressId == null) return;

    final senderId = context.read<AuthProvider>().currentUser?.uid ?? '';

    try {
      setState(() => _submitting = true);

      final orderId = widget.product.orderId;
      final orderDocId = orderId.toString();

      final receiveAddressPath =
          'users/${_recipient!.uid}/addresses/${_selectedAddressId!}';

      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderDocId)
          .update({
            'receive_id': _recipient!.uid,
            'receive_at': receiveAddressPath,
            'current_status': 1,
          });

      if (widget.product.imageUrl.isNotEmpty && senderId.isNotEmpty) {
        await _archiveProductImageToDelivery(
          imageUrl: widget.product.imageUrl,
          orderId: orderId,
          uploaderUid: senderId,
          status: 1,
        );
      }

      Get.snackbar(
        'สำเร็จ',
        'บันทึกผู้รับ/ที่อยู่ และรูปการส่งเรียบร้อย',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.off(() => const UserHomePage());
    } catch (e) {
      Get.snackbar(
        'ผิดพลาด',
        'บันทึกไม่สำเร็จ: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
