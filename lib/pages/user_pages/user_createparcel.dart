import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_delivery/pages/user_pages/user_home.dart';
import 'package:provider/provider.dart';
import 'package:mobile_delivery/providers/auth_provider.dart';
import 'package:mobile_delivery/models/user_address.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateParcelPage extends StatefulWidget {
  const CreateParcelPage({super.key});

  @override
  State<CreateParcelPage> createState() => _CreateParcelPageState();
}

class _CreateParcelPageState extends State<CreateParcelPage> {
  final _name = TextEditingController();
  final _picker = ImagePicker();
  XFile? _image;
  final db = FirebaseFirestore.instance;
  final supa = Supabase.instance.client;

  String? _selectedAddressId;

  int _navIndex = 0;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFD2C2F1);
    const cardBg = Color(0xFFF4EBFF);
    const borderCol = Color(0x55000000);

    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () => Get.off(() => const UserHomePage()),
        ),
        title: const Text(
          'สร้างสินค้า',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                color: cardBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: borderCol),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: _image == null
                                ? const Icon(Icons.inventory_2, size: 42)
                                : Image.file(
                                    File(_image!.path),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 28,
                            child: ElevatedButton(
                              onPressed: () async {
                                final XFile? img = await _openImagePopup(
                                  context,
                                );
                                if (img != null) {
                                  setState(() => _image = img);
                                  log('Picked: ${img.path}');
                                } else {
                                  log('No Image');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black87,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'เพิ่มรูปสินค้า',
                                style: TextStyle(fontSize: 12.5),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        'ชื่อสินค้า',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      _input(controller: _name, hint: 'ชื่อสินค้า'),

                      const SizedBox(height: 18),

                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFC9A9F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderCol),
                        ),
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'เลือกที่อยู่ผู้สั่ง',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 10),

                            if (user == null)
                              const Text('ยังไม่ได้เข้าสู่ระบบ'),

                            if (user != null)
                              StreamBuilder<List<UserAddress>>(
                                stream: userAddressesStream(user.uid),
                                builder: (context, snap) {
                                  if (snap.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }
                                  if (snap.hasError) {
                                    return const Text(
                                      'โหลดข้อมูลที่อยู่ไม่สำเร็จ',
                                    );
                                  }

                                  final addresses = snap.data ?? [];
                                  if (addresses.isEmpty) {
                                    return Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: borderCol),
                                      ),
                                      child: const Text(
                                        'ยังไม่มีที่อยู่ กรุณาเพิ่มที่อยู่ที่หน้าโปรไฟล์',
                                      ),
                                    );
                                  }

                                  return ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: addresses.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 10),
                                    itemBuilder: (_, i) {
                                      final addr = addresses[i];
                                      return _addressRadioTile(addr);
                                    },
                                  );
                                },
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_name.text.trim().isEmpty) {
                              Get.snackbar(
                                'ข้อมูลไม่ครบ',
                                'กรุณากรอกชื่อสินค้า',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }
                            if (_selectedAddressId == null) {
                              Get.snackbar(
                                'ยังไม่ได้เลือกที่อยู่',
                                'กรุณาเลือกที่อยู่ผู้สั่ง',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }

                            await _saveProductAndOrder();

                            Get.off(() => const UserHomePage());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('บันทึก'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
          if (i == 0) {
            Get.off(() => const UserHomePage());
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

  // ----------------------- Widgets -----------------------
  Widget _input({
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _addressRadioTile(UserAddress addr) {
    const borderCol = Color(0x55000000);
    final selected = _selectedAddressId == addr.id;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RadioListTile<String>(
        value: addr.id,
        groupValue: _selectedAddressId,
        onChanged: (v) => setState(() => _selectedAddressId = v),
        selected: selected,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        secondary: const Icon(Icons.map_outlined),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              addr.address,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            _miniMapForAddress(addr),
          ],
        ),
      ),
    );
  }

  Widget _miniMapForAddress(UserAddress addr) {
    const borderCol = Color(0x55000000);

    // ถ้าไม่มีพิกัด ให้แสดงกล่อง placeholder
    if (addr.lat == null || addr.lng == null) {
      return Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderCol),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.map_outlined, color: Colors.black54, size: 18),
            SizedBox(width: 6),
            Text('ไม่มีพิกัด'),
          ],
        ),
      );
    }

    final center = LatLng(addr.lat!, addr.lng!);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 64,
        child: AbsorbPointer(
          child: FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: 15.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.none,
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
                    width: 36,
                    height: 36,
                    child: const Icon(Icons.location_on, color: Colors.blue),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------- Image Picker Dialog -----------------------
  Future<XFile?> _openImagePopup(BuildContext context) async {
    XFile? picked;

    return showDialog<XFile?>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            final double preview = MediaQuery.of(ctx).size.width * 0.5;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: const Color(0xFFC9A9F5),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: preview,
                      height: preview,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: picked == null
                          ? Icon(Icons.camera_alt, size: preview * 0.45)
                          : Image.file(File(picked!.path), fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        final x = await _picker.pickImage(
                          source: ImageSource.camera,
                        );
                        if (x != null) setLocal(() => picked = x);
                      },
                      child: const Text('เปิดกล้อง'),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC9A9F5),
                              foregroundColor: Colors.black87,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () async {
                              final x = await _picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (x != null) setLocal(() => picked = x);
                            },
                            child: const Text('อัปโหลดรูปสินค้า'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 90,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () async {
                              final x = await _picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (x != null) setLocal(() => picked = x);
                            },
                            child: const Text('เลือกรูป'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () => Navigator.pop(ctx, null),
                            child: const Text('ยกเลิก'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () => Navigator.pop(ctx, picked),
                            child: const Text('ตกลง'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<String> _uploadProductImageToSupabase(XFile file) async {
    final bytes = await file.readAsBytes();
    final fileName = 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';

    await supa.storage
        .from('products')
        .uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

    final imageUrl = supa.storage.from('products').getPublicUrl(fileName);
    return imageUrl;
  }

  Future<int> _getNextOrderId() async {
    final snap = await db
        .collection('orders')
        .orderBy('order_id', descending: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return 1;
    final lastId = int.tryParse(snap.docs.first['order_id'].toString()) ?? 0;
    return lastId + 1;
  }

  Future<int> _getNextProductId() async {
    final snap = await db
        .collection('products')
        .orderBy('product_id', descending: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return 1;
    final lastId = int.tryParse(snap.docs.first['product_id'].toString()) ?? 0;
    return lastId + 1;
  }

  Future<void> _saveProductAndOrder() async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;

    if (_name.text.trim().isEmpty) {
      Get.snackbar('กรอกไม่ครบ', 'กรุณากรอกชื่อสินค้า');
      return;
    }

    if (_image == null) {
      Get.snackbar('ไม่มีรูปสินค้า', 'กรุณาเพิ่มรูปสินค้า');
      return;
    }

    if (_selectedAddressId == null) {
      Get.snackbar('ยังไม่ได้เลือกที่อยู่', 'กรุณาเลือกที่อยู่ผู้ส่ง');
      return;
    }

    try {
      final imageUrl = await _uploadProductImageToSupabase(_image!);

      final newOrderId = await _getNextOrderId();
      final newProductId = await _getNextProductId();

      final sendAddressRef = db
          .collection('users')
          .doc(user!.uid)
          .collection('addresses')
          .doc(_selectedAddressId);

      final orderData = {
        'order_id': newOrderId,
        'send_id': user.uid,
        'receive_id': '',
        'rider_id': '',
        'send_at': sendAddressRef,
        'receive_at': null,
        'is_active': true,
        'current_status': 0,
      };
      await db.collection('orders').doc(newOrderId.toString()).set(orderData);

      final productData = {
        'product_id': newProductId,
        'product_name': _name.text.trim(),
        'order_id': newOrderId,
        'image_url': imageUrl,
      };
      await db
          .collection('products')
          .doc(newProductId.toString())
          .set(productData);

      Get.snackbar('สำเร็จ', 'สร้างสินค้าและคำสั่งซื้อเรียบร้อย');
      Get.off(() => const UserHomePage());
    } catch (e) {
      Get.snackbar('ผิดพลาด', e.toString());
    }
  }
}
