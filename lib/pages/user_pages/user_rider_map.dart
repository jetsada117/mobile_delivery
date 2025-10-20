// lib/pages/user_pages/user_rider_map.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RiderMapPage extends StatelessWidget {
  const RiderMapPage({
    super.key,
    required this.latLng,
    this.riderName = 'นายสมชาย เดลิเวอรี่',
    this.statusText = '[3]',
    this.phone = '012-345-6789',
    this.plate = '8กพ 877',
    this.avatarUrl = 'https://i.pravatar.cc/100?img=12',
  });

  final LatLng latLng;
  final String riderName;
  final String statusText;
  final String phone;
  final String plate;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFD2C2F1);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('แผนที่', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // แผนที่
          FlutterMap(
            options: MapOptions(
              initialCenter: latLng,
              initialZoom: 14.5,
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
                    point: latLng,
                    width: 36,
                    height: 36,
                    child: const Icon(Icons.location_on, color: Colors.black87),
                  ),
                ],
              ),
            ],
          ),

          // แผงข้อมูลไรเดอร์ด้านล่าง
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
                  )
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(avatarUrl),
                    onBackgroundImageError: (_, __) {},
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ข้อมูลไรเดอร์',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 16)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text('ชื่อ : $riderName'),
                            ),
                            Text('สถานะ: $statusText'),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text('เบอร์โทร : $phone'),
                        const SizedBox(height: 2),
                        Text('ทะเบียนรถ : $plate'),
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
