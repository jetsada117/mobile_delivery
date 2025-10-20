// lib/pages/rider/rider_delivery_success_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_delivery/pages/rider_pages/rider_home.dart';

class RiderDeliverySuccessPage extends StatelessWidget {
  const RiderDeliverySuccessPage({
    super.key,
    required this.pickupImage,
    required this.deliveredImage,
  });

  final File pickupImage; // รูปรับออเดอร์
  final File deliveredImage; // รูปจัดส่งสำเร็จ

  static const bg = Color(0xFFD2C2F1);
  static const cardBg = Color(0xFFF4EBFF);
  static const borderCol = Color(0x55000000);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'ส่งพัสดุสำเร็จ',
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
                    _StatusPill(icon: Icons.local_shipping_outlined),
                    _StatusPill(icon: Icons.home_outlined, iconColor: Colors.green), // สำเร็จ
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

              // แถบโชว์รูป: ซ้าย=รับออเดอร์ ขวา=จัดส่งสำเร็จ
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
                            pickupImage,
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
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            deliveredImage,
                            width: 74,
                            height: 56,
                            fit: BoxFit.cover,
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

              const SizedBox(height: 18),

              // ⬇️ ปุ่ม "ยืนยันการส่ง"
              Center(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      // กลับไปหน้า RiderHomePage และล้างสแตกเพื่อไม่ให้ย้อนกลับ
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const RiderHomePage(),
                        ),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D72FF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: const Text('ยืนยันการส่ง'),
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
