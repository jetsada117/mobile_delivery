import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import 'rider_delivery_success_page.dart';

class RiderDeliveringPage extends StatefulWidget {
  const RiderDeliveringPage({super.key, required this.orderImage});

  final File orderImage;

  @override
  State<RiderDeliveringPage> createState() => _RiderDeliveringPageState();
}

class _RiderDeliveringPageState extends State<RiderDeliveringPage> {
  static const bg = Color(0xFFD2C2F1);
  static const cardBg = Color(0xFFF4EBFF);
  static const borderCol = Color(0x55000000);

  final _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'สถานะการส่ง',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // แถวไอคอนสถานะ
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderCol),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    _StatusPill(icon: Icons.location_on_outlined),
                    _StatusPill(icon: Icons.check_circle_outline),
                    _StatusPill(
                      icon: Icons.local_shipping_outlined,
                      iconColor: Colors.green,
                    ), // กำลังส่ง
                    _StatusPill(icon: Icons.home_outlined),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // แผนที่
              SizedBox(
                height: 270,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: const LatLng(16.2458, 103.2500),
                      initialZoom: 15.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.thunderforest.com/atlas/{z}/{x}/{y}.png?apikey=6949d257c8de4157a028c7a44b05af3d',
                        userAgentPackageName: 'com.example.mobile_delivery',
                      ),
                      const MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(16.2458, 103.2500),
                            width: 36,
                            height: 36,
                            child: Icon(
                              Icons.location_on,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // แถบล่าง: ซ้าย = รูปที่รับออเดอร์ / ขวา = กล้องสำหรับปลายทาง (กดเพื่อเปิดป็อปอัพ)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFC9A9F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('รับออเดอร์'),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            widget.orderImage,
                            width: 74,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('จัดส่งสำเร็จ'),
                        const SizedBox(height: 6),
                        // ปุ่มกล้อง: เปิดป็อปอัพให้ถ่าย/อัปโหลด แล้วไปหน้าสำเร็จ
                        InkWell(
                          onTap: () async {
                            final XFile? delivered = await _openProofSheet(
                              context,
                            );
                            if (!mounted || delivered == null) return;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RiderDeliverySuccessPage(
                                  pickupImage: widget.orderImage,
                                  deliveredImage: File(delivered.path),
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 74,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0x55000000),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.photo_camera_outlined,
                              size: 26,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // การ์ดข้อมูลผู้รับ
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderCol),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: const [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(
                        'https://i.pravatar.cc/100?img=12',
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ข้อมูลผู้รับ',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 4),
                          Text('ชื่อ: นายสมชาย เด็กดี'),
                          Text('เบอร์โทร: 012-345-6789'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ป็อปอัพตามภาพตัวอย่าง: กดไอคอนกล้อง = ถ่ายภาพ, ปุ่มขวา = อัปโหลดรูป
  /// กด "ยืนยัน" แล้วจะคืนค่า XFile ของรูปนั้น (ใช้ไปหน้า "ส่งพัสดุสำเร็จ")
  Future<XFile?> _openProofSheet(BuildContext context) async {
    XFile? picked;
    final nameCtl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            final blackBtn = ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            );

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: const Color(0xFFC9A9F5),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ไอคอนกล้องด้านบน (กด = ถ่ายรูป)
                    InkWell(
                      onTap: () async {
                        final x = await _picker.pickImage(
                          source: ImageSource.camera,
                        );
                        if (x != null) {
                          setLocal(() {
                            picked = x;
                            nameCtl.text = x.name;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 72,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF000000)),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.photo_camera, size: 28),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // แถว: ชื่อรูป (readOnly) + ปุ่มอัปโหลดรูปภาพ
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: nameCtl,
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: 'ชื่อรูป',
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () async {
                              final x = await _picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (x != null) {
                                setLocal(() {
                                  picked = x;
                                  nameCtl.text = x.name;
                                });
                              }
                            },
                            style: blackBtn,
                            child: const Text('อัปโหลดรูปภาพ'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ปุ่ม ยกเลิก / ยืนยัน
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            style: blackBtn,
                            child: const Text('ยกเลิก'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: picked == null
                                ? null
                                : () => Navigator.pop(ctx, true),
                            style: blackBtn,
                            child: const Text('ยืนยัน'),
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

    if (result == true) return picked;
    return null;
  }
}

/* widgets เฉพาะไฟล์นี้ */
class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    this.iconColor = Colors.black87, // << เพิ่ม
  });
  final IconData icon;
  final Color iconColor; // << เพิ่ม

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x55000000)),
      ),
      child: Icon(icon, size: 20, color: iconColor), // << ใช้สี
    );
  }
}
