// lib/pages/user_pages/user_rider_map.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RiderMapPage extends StatelessWidget {
  const RiderMapPage({
    super.key,
    this.riderLatLng, // <-- ทำให้เป็น nullable
    required this.senderLatLng,
    required this.receiverLatLng,
    this.riderName,
    this.statusText,
    this.phone,
    this.plate,
    this.avatarUrl,
  });

  final LatLng? riderLatLng; // <-- nullable
  final LatLng senderLatLng;
  final LatLng receiverLatLng;

  // ข้อมูลไรเดอร์ก็ให้ nullable เช่นกัน
  final String? riderName;
  final String? statusText;
  final String? phone;
  final String? plate;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFD2C2F1);

    // โฟกัสเริ่มที่ “กลางระหว่างผู้ส่งกับผู้รับ”
    final initial = LatLng(
      (senderLatLng.latitude + receiverLatLng.latitude) / 2,
      (senderLatLng.longitude + receiverLatLng.longitude) / 2,
    );

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text(
          'แผนที่',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: riderLatLng ?? initial,
              initialZoom: 13.5,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.thunderforest.com/atlas/{z}/{x}/{y}.png?apikey=6949d257c8de4157a028c7a44b05af3d',
                userAgentPackageName: 'com.example.mobile_delivery',
              ),
              // วาด Marker เฉพาะที่มี
              MarkerLayer(
                markers: [
                  // ผู้ส่ง
                  Marker(
                    point: senderLatLng,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.storefront,
                      color: Colors.green,
                      size: 36,
                    ),
                  ),
                  // ผู้รับ
                  Marker(
                    point: receiverLatLng,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.home,
                      color: Colors.blueAccent,
                      size: 36,
                    ),
                  ),
                  // ไรเดอร์ (มีค่อยวาด)
                  if (riderLatLng != null)
                    Marker(
                      point: riderLatLng!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.delivery_dining,
                        color: Colors.redAccent,
                        size: 40,
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Legend มุมขวาบน (ถ้ามีไรเดอร์จะโชว์เพิ่มอีกอัน)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.storefront, color: Colors.green, size: 18),
                  const SizedBox(width: 4),
                  const Text('ผู้ส่ง'),
                  const SizedBox(width: 8),
                  if (riderLatLng != null) ...[
                    const Icon(
                      Icons.delivery_dining,
                      color: Colors.redAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    const Text('ไรเดอร์'),
                    const SizedBox(width: 8),
                  ],
                  const Icon(Icons.home, color: Colors.blueAccent, size: 18),
                  const SizedBox(width: 4),
                  const Text('ผู้รับ'),
                ],
              ),
            ),
          ),

          // แผงข้อมูลไรเดอร์ด้านล่าง “แสดงเฉพาะเมื่อมีไรเดอร์”
          if (riderLatLng != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF4EBFF),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          (avatarUrl != null && avatarUrl!.isNotEmpty)
                          ? NetworkImage(avatarUrl!)
                          : null,
                      child: (avatarUrl == null || avatarUrl!.isEmpty)
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ข้อมูลไรเดอร์',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Text('ชื่อ : ${riderName ?? '-'}'),
                              ),
                              Text('สถานะ: ${statusText ?? '-'}'),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text('เบอร์โทร : ${phone ?? '-'}'),
                          const SizedBox(height: 2),
                          Text('ทะเบียนรถ : ${plate ?? '-'}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
