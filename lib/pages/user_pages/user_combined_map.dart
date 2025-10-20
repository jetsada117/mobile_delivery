import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CombinedMapPage extends StatelessWidget {
  const CombinedMapPage({
    super.key,
    required this.points, // ตำแหน่งหมุดทั้งหมด
    this.riderName = 'นายสมชาย เดลิเวอรี่',
    this.statusText = '[3]',
    this.phone = '012-345-6789',
    this.plate = '8กพ 877',
    this.avatarUrl = 'https://i.pravatar.cc/100?img=15',
  });

  final List<LatLng> points;
  final String riderName;
  final String statusText;
  final String phone;
  final String plate;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    final center = points.isNotEmpty
        ? points.first
        : const LatLng(16.2458, 103.25);

    return Scaffold(
      appBar: AppBar(
        title: const Text('แผนที่รวม'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(initialCenter: center, initialZoom: 13.0),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.thunderforest.com/atlas/{z}/{x}/{y}.png?apikey=6949d257c8de4157a028c7a44b05af3d',
                userAgentPackageName: 'com.example.mobile_delivery',
              ),
              MarkerLayer(
                markers: points.map((p) {
                  return Marker(
                    point: p,
                    width: 36,
                    height: 36,
                    child: const Icon(Icons.location_on, color: Colors.black87),
                  );
                }).toList(),
              ),
            ],
          ),

          // การ์ดข้อมูลไรเดอร์ด้านล่าง
          Positioned(
            left: 12,
            right: 12,
            bottom: 16,
            child: _InfoCard(
              riderName: riderName,
              statusText: statusText,
              phone: phone,
              plate: plate,
              avatarUrl: avatarUrl,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.riderName,
    required this.statusText,
    required this.phone,
    required this.plate,
    required this.avatarUrl,
  });

  final String riderName;
  final String statusText;
  final String phone;
  final String plate;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFF4EBFF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(avatarUrl),
              onBackgroundImageError: (_, __) {},
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ข้อมูลไรเดอร์',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(child: Text('ชื่อ : $riderName')),
                      Text('สถานะ : $statusText'),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('เบอร์โทร : $phone'),
                  Text('ทะเบียนรถ : $plate'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
